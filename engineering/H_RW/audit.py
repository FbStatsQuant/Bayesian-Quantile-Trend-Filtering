#!/usr/bin/env python3
"""Audit reachable Git objects, exempt paths, and checksums without emitting contents."""
import argparse
import io
import html
from collections import Counter, defaultdict
from contextlib import contextmanager
from functools import lru_cache
from hashlib import sha256
from pathlib import Path
import posixpath
import re
import subprocess
import tarfile
import tempfile

HERE = Path(__file__).resolve().parent
PUBLIC_EMAIL = re.compile(rb"(?<![\w.+-])[f]b31@[r]ice\.edu(?![\w-]|\.[\w-])", re.I)
LOGIN = re.compile(rb"(?<![\w])[f]b31(?![\w])", re.I)
MANIFEST_ENTRY = re.compile(rb"^([a-fA-F0-9]{64}) [ *](.+)$")
SECRET_MARKER = re.compile(
    rb"-----BEGIN (?:[A-Z0-9]+ )*PRIVATE KEY-----"
    rb"|(?:ghp_|gho_|github_pat_|xox[baprs]-)[A-Za-z0-9_-]{24,}"
    rb"|AKIA[A-Z0-9]{16}|AIza[A-Za-z0-9_-]{35}"
)
SEALED = (
    b"experiments/interior_quantiles/individual_nots_20261003/",
    b"experiments/joint_upper_levels/",
    b"engineering/E07_Tuning_Free/joint_gibbs/validate/inputs/",
    b"Simulations/Individual/NOTS/inner_individual/",
    b"Simulations/Joint/NOTS/",
    b"Engineering/E07_Tuning_Free/joint_gibbs/validate/inputs/",
)
AUTHOR_FILES = {b"paper/main.tex", b"Project_Paper/main.tex", b"CITATION.cff"}
OWNER_PDF = {b"Papers/Large Prior.pdf", b"literature/Large Prior.pdf"}
PAPER_MAIN = {b"paper/main.pdf", b"Project_Paper/main.pdf"}
MIB = 1024 * 1024


def rules():
    return tuple(
        (re.compile(line[6:].split(b"==>", 1)[0]), line.split(b"==>", 1)[1])
        for line in (HERE / "replace-text.txt").read_bytes().splitlines()
        if line
    )


def removal_rules():
    return [
        re.compile(line[6:])
        for line in (HERE / "remove-paths.txt").read_bytes().splitlines()
        if line
    ]


def replace(data, patterns):
    for pattern, target in patterns:
        data = pattern.sub(target, data)
    return data


@lru_cache(maxsize=1)
def scan_markers(patterns):
    # Each marker is necessary for its rule. Unknown rule sets use the full scan.
    markers = (
        b"/projects/", b"/home/", b"~", b"@", b"projects/", b"/projects/",
        b"users", b"/rhf/allocations/", b"groupid=", b"", b"userid=",
        b"comm" b"ons", b"comm" b"ons", b"rice" b".edu", b"", b"owl" b"s",
        b"rice" b".edu", b"226.96.",
    )
    # A different rule file may have different mandatory literals, so fall back.
    encoded_rules = b"".join(b"regex:" + rule.pattern + b"==>" + target + b"\n"
                             for rule, target in patterns)
    use_markers = sha256(encoded_rules).hexdigest() == (
        "bf490a54de782f6f09bc3d5fe53935e311ba0d94a2916828168c163d24c49fd0"
    )
    return markers if use_markers else (b"",) * len(patterns)


def hits(data, patterns):
    lower = data.lower()
    return Counter(
        (idx, target.decode().replace(r"\1", "").strip("()"))
        for idx, ((pattern, target), marker) in enumerate(zip(patterns, scan_markers(patterns)), 1)
        if marker in lower
        for _ in pattern.finditer(data)
    )


def git(*args, repo="."):
    return subprocess.check_output(["git", "-C", str(repo), *args])


@contextmanager
def blobs(repo, object_type=b"blob"):
    args = ["git", "-C", str(repo), "cat-file", "--batch"]
    with subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE) as proc:
        def get(oid):
            proc.stdin.write(oid + b"\n")
            proc.stdin.flush()
            found, kind, size = proc.stdout.readline().split()
            if found != oid or kind != object_type:
                raise ValueError("unexpected Git object")
            data = proc.stdout.read(int(size))
            if len(data) != int(size) or proc.stdout.read(1) != b"\n":
                raise ValueError("truncated Git object")
            return data

        yield get
        proc.stdin.close()
        if proc.wait() != 0:
            raise RuntimeError("git cat-file failed")


def tree_entries(tree, repo):
    records = git("ls-tree", "-rz", tree, repo=repo).split(b"\0")
    for record in records:
        if record:
            meta, path = record.split(b"\t", 1)
            mode, kind, oid = meta.split()
            yield path, (mode, kind, oid)


def all_paths(repo):
    trees = set(git("log", "--all", "--format=%T", repo=repo).split())
    paths = defaultdict(set)
    for tree in sorted(trees):
        for path, (_, kind, oid) in tree_entries(tree, repo):
            if kind == b"blob":
                paths[path].add(oid)
    return paths


def manifest(path):
    name = path.rsplit(b"/", 1)[-1].lower()
    return b"sha256sums" in name or name.endswith(b".sha256")


def source(path):
    return path.startswith((b"lean/", b"Lean/")) and (
        path.endswith(b".lean")
        or path.rsplit(b"/", 1)[-1] in
        {b"lean-toolchain", b"lakefile.toml", b"lake-manifest.json"}
    )


def manifest_entries(data):
    return [entry.groups() for line in data.splitlines()
            if (entry := MANIFEST_ENTRY.fullmatch(line))]


def aliases(path, target):
    """Include the manifest root and package ancestors for archived checksum lists."""
    if target.startswith(b"/"):
        # Absolute records can refer to files that survive at a repo-relative suffix.
        parts = target.split(b"/")[1:]
        return [b"/".join(parts[index:]) for index in range(len(parts) - 1)]
    parent = posixpath.dirname(path)
    options = [
        posixpath.normpath(posixpath.join(parent, target)),
        posixpath.normpath(target),
    ]
    while parent:
        parent = posixpath.dirname(parent)
        options.append(posixpath.normpath(posixpath.join(parent, target)))
    return list(dict.fromkeys(options))


def protected_paths(paths, manifest_targets, contents):
    protected = defaultdict(set)
    for path in paths:
        if path.startswith(SEALED):
            protected[path].add(b"[sealed directory]")
        if source(path):
            protected[path].add(b"[Lean source/build input]")
        if manifest(path):
            protected[path].add(path)
        if path in OWNER_PDF:
            protected[path].add(b"[owner PDF]")
    for path, targets in manifest_targets.items():
        for _, target in targets:
            for resolved in aliases(path, target):
                if resolved in paths:
                    protected[resolved].add(path)
    for path, versions in paths.items():
        for oid in versions:
            if contents[oid]:
                protected[path].update(contents[oid])
    return {path: refs for path, refs in protected.items() if refs}


def safe(field, patterns):
    field = LOGIN.sub(b"<LOGIN>", replace(field, patterns))
    return field.decode("utf-8", "backslashreplace").replace("\t", r"\t").replace("\n", r"\n")


def recommendation(path, drops, protected, size):
    if path in OWNER_PDF:
        return "Owner handles separately"
    if drops:
        return "Purge; confirm archive where needed"
    if path in PAPER_MAIN:
        return "Keep current paper; review stale versions"
    if protected:
        return "Keep byte-exact pending manifest or seal decision"
    if size >= 5 * MIB:
        return "Archive and strip by blob ID unless HQ approves"
    if path.endswith((b".rds", b".RData", b".rda", b".tar.gz", b".zip")):
        return "Review provenance; keep reproducibility input or archive large output"
    return "Keep first-party artifact if needed; review provenance"


def manifest_index(paths, get):
    manifest_targets = {
        path: {row for oid in versions for row in manifest_entries(get(oid))}
        for path, versions in paths.items() if manifest(path)
    }
    by_digest = defaultdict(set)
    for path, targets in manifest_targets.items():
        for digest, _ in targets:
            by_digest[digest.lower()].add(path)
    return manifest_targets, by_digest


def login_locations(data):
    public = {entry.start() for entry in PUBLIC_EMAIL.finditer(data)}
    return [(entry.start(), "author email" if entry.start() in public else "other")
            for entry in LOGIN.finditer(data)]


def pdf_links(data):
    # Older Poppler versions do not implement pdfinfo -url.
    with tempfile.NamedTemporaryFile(suffix=".pdf") as source:
        source.write(data)
        source.flush()
        result = subprocess.run(
            ["pdftohtml", "-xml", "-i", "-stdout", source.name], stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, check=False,
        )
    links = re.findall(rb'<a href="([^"]+)"', result.stdout)
    decoded = html.unescape(b"\n".join(links).decode("utf-8", "replace")).encode()
    return "PDF links", decoded, result.returncode != 0



def container_views(data, decode):
    if not decode:
        return
    if data.startswith(b"%PDF-"):
        for view, command in (
            ("PDF text", ["pdftotext", "-", "-"]),
            ("PDF metadata", ["pdfinfo", "-meta", "-"]),
        ):
            result = subprocess.run(command, input=data, stdout=subprocess.PIPE,
                                    stderr=subprocess.DEVNULL, check=False)
            yield view, result.stdout, result.returncode != 0
        yield pdf_links(data)
    elif data.startswith(b"\x1f\x8b"):
        try:
            with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
                for member in archive:
                    if member.isfile() and member.size <= 64 * MIB:
                        with archive.extractfile(member) as stream:
                            yield "tar member " + member.name, stream.read(), False
                    elif member.isfile():
                        yield "oversized tar member " + member.name, b"", True
        except tarfile.TarError:
            # Most other gzip streams here are R serialization, not archives.
            pass



def audit(repo, output, extract_pdfs):
    output.mkdir(parents=True, exist_ok=True)
    patterns = rules()
    drops = removal_rules()
    paths = all_paths(repo)
    with blobs(repo) as get:
        manifest_targets, by_digest = manifest_index(paths, get)
        objects = git("rev-list", "--all", "--objects", "--no-object-names", repo=repo)
        listing = subprocess.check_output(
            ["git", "-C", str(repo), "cat-file", "--batch-check=%(objectname) %(objecttype) %(objectsize)"],
            input=objects,
        )
        size = {}
        raw_hits = {}
        decoded_hits = defaultdict(list)
        pdfs = set()
        covered = {}
        binary = set()
        secrets = set()
        login = {}
        locations = defaultdict(list)
        decode_fail = defaultdict(list)
        for row in listing.splitlines():
            oid, kind, length = row.split()
            if kind != b"blob":
                continue
            size[oid] = int(length)
            data = get(oid)
            covered[oid] = by_digest.get(sha256(data).hexdigest().encode(), set())
            # Large numeric CSVs are scanned like other objects, in bounded memory.
            raw_hits[oid] = hits(data, patterns)
            if SECRET_MARKER.search(data):
                secrets.add(oid)
            if b"\0" in data[:8192] or data.startswith(b"%PDF-"):
                binary.add(oid)
            if data.startswith(b"%PDF-"):
                pdfs.add(oid)
            locations[oid].extend(("raw", offset, category)
                                  for offset, category in login_locations(data))
            for view, content, failed in container_views(data, extract_pdfs):
                if failed:
                    decode_fail[oid].append(view)
                matches = hits(content, patterns)
                if matches:
                    decoded_hits[oid].append((view, matches))
                locations[oid].extend((view, offset, category)
                                      for offset, category in login_locations(content))
                if SECRET_MARKER.search(content):
                    secrets.add(oid)
            if locations[oid]:
                email = sum(category == "author email" for _, _, category in locations[oid])
                login[oid] = (email, len(locations[oid]) - email)
    protected = protected_paths(paths, manifest_targets, covered)
    (output / "protected.nul").write_bytes(b"\0".join(sorted(protected)) + b"\0")
    totals = Counter(blobs=len(size), paths=len(paths), protected_paths=len(protected),
                     raw_matching_blobs=sum(bool(counts) for counts in raw_hits.values()),
                     raw_matches=sum(sum(counts.values()) for counts in raw_hits.values()),
                     decoded_matching_blobs=len(decoded_hits),
                     decoded_matches=sum(sum(counts.values()) for views in decoded_hits.values()
                                         for _, counts in views),
                     container_decode_errors=sum(map(len, decode_fail.values())), secret_marker_blobs=len(secrets))
    with (
        (output / "findings.tsv").open("w") as findings,
        (output / "login.tsv").open("w") as logins,
        (output / "inventory.tsv").open("w") as inventory,
        (output / "path-hits.tsv").open("w") as path_hits,
        (output / "login-locations.tsv").open("w") as login_offsets,
        (output / "decode-errors.tsv").open("w") as decode_errors,
    ):
        print("path\tblob\tchannel\trules (line:replacement=count)\tdisposition\tmanifest/protection", file=findings)
        print("path\tblob\tauthor email\tother login\tother classification", file=logins)
        print("path\tblob\tbytes\trecommendation", file=inventory)
        print("path\trule lines", file=path_hits)
        print("blob\tchannel\tbyte offset (zero based)\ttype", file=login_offsets)
        for oid, occurrences in sorted(locations.items()):
            for view, offset, category in occurrences:
                print(oid.decode(), safe(view.encode(), patterns), offset, category,
                      sep="\t", file=login_offsets)
        print("path\tblob\tdecoder", file=decode_errors)
        for path, versions in sorted(paths.items()):
            name = safe(path, patterns)
            path_rules = hits(path, patterns)
            if path_rules:
                print(name, ",".join(str(line) for line, _ in path_rules), sep="\t", file=path_hits)
            purged = any(p.search(path) for p in drops)
            protection = "; ".join(safe(field, patterns) for field in sorted(protected.get(path, ())))
            for oid in sorted(versions):
                obj = oid.decode()
                disposition = ("purge" if purged else "protected" if protection
                               else "binary review" if oid in binary else "replace")
                for view in decode_fail[oid]:
                    print(name, obj, safe(view.encode(), patterns), sep="\t", file=decode_errors)
                for channel, counts in [("raw", raw_hits[oid]), *decoded_hits[oid]]:
                    if counts:
                        summary = ", ".join(f"{i}:{label}={n}" for (i, label), n in sorted(counts.items()))
                        print(name, obj, safe(channel.encode(), patterns), summary, disposition, protection, sep="\t", file=findings)
                        kind = "raw" if channel == "raw" else "decoded"
                        totals[f"{kind} path/blob rows ({disposition})"] += 1
                if oid in login:
                    email, other = login[oid]
                    classification = (
                        "sealed or manifested" if protection else "other, login outside rewrite scope"
                    ) if other else "author email only"
                    print(name, obj, email, other, classification, sep="\t", file=logins)
                    totals["login path/blob rows"] += 1
                    totals["author email occurrences by path/blob"] += email
                    if other:
                        totals[f"other login occurrences by path/blob ({classification})"] += other
                if size[oid] >= MIB or oid in pdfs or (
                    path.endswith(b".txt") and re.search(rb"(?:Brantley_2020|Onizuka_2023)", path)
                ):
                    note = recommendation(path, purged, protection, size[oid])
                    print(name, obj, size[oid], note, sep="\t", file=inventory)
                    totals["inventory path/blob rows"] += 1
    print(*[f"{key}: {value}" for key, value in sorted(totals.items())], sep="\n")


def checksum_aliases(path, target):
    options = aliases(path, target)
    parent = posixpath.dirname(path)
    if target.startswith(b"/"):
        marker = b"/" + parent.rsplit(b"/", 1)[-1] + b"/"
        if marker in target:
            options.insert(0, posixpath.join(parent, target.rsplit(marker, 1)[1]))
    if b"/Munich Rent/" in path or b"/munich_rent/" in path:
        if b"/Others/results_pmala_k2/" in path:
            filename = posixpath.basename(target)
            if filename in {b"posterior_summary.csv", b"sampler_diagnostics.csv"}:
                options.insert(0, posixpath.join(parent, filename))
            if filename == b"munich.rda":
                options.insert(0, posixpath.normpath(posixpath.join(parent, b"../../data", filename)))
    return options



def checksums(repo):
    entries = dict(tree_entries(b"HEAD", repo))
    patterns = rules()
    print("manifest\tok\tmismatch\tmissing\tunsupported lines")
    with blobs(repo) as get:
        digests = {}
        for path, (_, kind, oid) in sorted(entries.items()):
            if kind != b"blob" or not manifest(path):
                continue
            data = get(oid)
            rows = manifest_entries(data)
            totals = Counter()
            for expected, target in rows:
                available = [candidate for candidate in checksum_aliases(path, target) if candidate in entries]
                if not available:
                    totals["missing"] += 1
                    continue
                actual = []
                for candidate in available:
                    _, candidate_kind, candidate_oid = entries[candidate]
                    if candidate_kind != b"blob":
                        continue
                    if candidate_oid not in digests:
                        digests[candidate_oid] = sha256(get(candidate_oid)).hexdigest().encode()
                    actual.append(digests[candidate_oid])
                totals["ok" if expected.lower() in actual else "mismatch"] += 1
            print(safe(path, patterns), totals["ok"], totals["mismatch"], totals["missing"],
                  len(data.splitlines()) - len(rows), sep="\t")


def compare(before, after, commit_map, protected_file, stripped=None):
    protected = set(protected_file.read_bytes().split(b"\0"))
    drops = removal_rules()
    stripped_ids = set(stripped.read_bytes().split()) if stripped else set()
    mapping = [line.split() for line in commit_map.read_bytes().splitlines()[1:]]
    zero = b"0" * len(mapping[0][0])
    compared = set()
    totals = Counter()
    def metadata(data):
        headers, message = data.split(b"\n\n", 1)
        fields = headers.splitlines()
        tree = fields[0].split()[1]
        identity = tuple(line for line in fields if line.startswith((b"author ", b"committer ", b"encoding ")))
        return tree, (identity, message)

    with (
        blobs(before) as old_blob, blobs(after) as new_blob,
        blobs(before, b"commit") as old_commit, blobs(after, b"commit") as new_commit,
    ):
        for old, new in mapping:
            if new == zero:
                totals["pruned commits"] += 1
                continue
            old_tree, old_metadata = metadata(old_commit(old))
            new_tree, new_metadata = metadata(new_commit(new))
            totals["commit metadata comparisons"] += 1
            if old_metadata != new_metadata:
                totals["commit metadata changes"] += 1
            if (old_tree, new_tree) in compared:
                continue
            compared.add((old_tree, new_tree))
            after_files = dict(tree_entries(new_tree, after))
            for path, original in tree_entries(old_tree, before):
                if original[2] in stripped_ids or any(p.search(path) for p in drops):
                    if path in after_files:
                        totals["unexpected retained path occurrences"] += 1
                    continue
                rewritten = after_files.get(path)
                if path in protected:
                    totals["protected tree/path comparisons"] += 1
                    if original != rewritten:
                        totals["protected changes"] += 1
                if path in AUTHOR_FILES:
                    totals["author-file tree/path comparisons"] += 1
                    totals["author-file comparisons " + path.decode()] += 1
                    original_emails = PUBLIC_EMAIL.findall(old_blob(original[2]))
                    totals["author emails compared"] += len(original_emails)
                    if rewritten is None or original_emails != PUBLIC_EMAIL.findall(new_blob(rewritten[2])):
                        totals["author email changes"] += 1
    print(*[f"{key}: {value}" for key, value in sorted(totals.items())], sep="\n")
    if any(totals[key] for key in ("protected changes", "author email changes", "commit metadata changes",
                                  "unexpected retained path occurrences", "pruned commits")):
        raise SystemExit(1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    scan = commands.add_parser("scan")
    scan.add_argument("repo", type=Path)
    scan.add_argument("output", type=Path)
    scan.add_argument("--pdf-text", action="store_true", help="also inspect PDFs and gzip tar archives")
    manifests = commands.add_parser("checksums")
    manifests.add_argument("repo", type=Path)
    verify = commands.add_parser("compare")
    verify.add_argument("before", type=Path)
    verify.add_argument("after", type=Path)
    verify.add_argument("commit_map", type=Path)
    verify.add_argument("protected", type=Path)
    verify.add_argument("--strip", type=Path)
    args = parser.parse_args()
    if args.command == "scan":
        audit(args.repo, args.output, args.pdf_text)
    elif args.command == "checksums":
        checksums(args.repo)
    else:
        compare(args.before, args.after, args.commit_map, args.protected, args.strip)


if __name__ == "__main__":
    main()
