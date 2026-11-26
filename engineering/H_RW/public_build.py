"""Build and verify the publication tree for each commit in the pinned lineage."""
import csv
from functools import lru_cache
from hashlib import sha256
import os
from pathlib import Path
import posixpath
import re
import subprocess
import sys

import audit

HERE = Path(__file__).resolve().parent
PATTERNS = audit.rules()
DROP = audit.removal_rules()
APPROVED_MESSAGES = set((HERE / "message-fingerprints.txt").read_bytes().split())
ARCHIVES = re.compile(
    rb"^(?:experiments/interior_quantiles/individual_nots_20261003|"
    rb"Simulations/Individual/NOTS/inner_individual)/"
    rb"(?:S_b0001/deployment/package_20261008\.tar\.gz|"
    rb"deployment/(?:upload_20261003T213406Z/package|validation_1785936)\.tar\.gz)$"
)
OFFLINE = b"engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256"
OFFLINE_NOTE = b"The E-09 manifest includes targets archived offline in the private record.\n"
SPOD_DIR = b"applications/Air Quality/"
SPOD_CSV = SPOD_DIR + b"spod_s08_d_2018-06-15_10s.csv"
RAW_NAME = b"S08_2018-06-15.csv"
RAW_SHA = "6086e8bdc1260cb90ca9250262aa7fc612a5e6e2d91490b7696f3e44f95cd7c3"
RDS_SHA = "7034864ae177b222d19d2df68347d1112f5491703fbeb5636adff05a07b76261"
CSV_SHA = "45e04964b2ea51b49c244e7b4778652300435cd2dd035a9be0d4cc73793ee2a0"
TRAILER = re.compile(rb"[A-Za-z0-9-]+:[ \t]")
AUTHOR_LINE = re.compile(rb"[ \t]*(?:author|committer|co-authored-by|signed-off-by):", re.I)
EMAIL = re.compile(rb"[A-Za-z0-9_.+%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
NOTE_SUFFIX = b".PUBLICATION.md"


def private_name(path):
    return audit.safe(path, PATTERNS)


def edit_message(message):
    if sha256(message).hexdigest().encode() not in APPROVED_MESSAGES:
        return message
    lines = message.splitlines(keepends=True)
    last = len(lines)
    while last and not lines[last - 1].strip():
        last -= 1
    first = last
    while first and lines[first - 1].strip():
        first -= 1
    is_trailer = first > 0 and all(
        TRAILER.match(line) or line.startswith((b" ", b"\t")) for line in lines[first:last]
    )
    return b"".join(
        line if AUTHOR_LINE.match(line) or (is_trailer and idx >= first) else edit_text(line)
        for idx, line in enumerate(lines)
    )


def edit_text(data):
    edited = audit.replace(data, PATTERNS)
    if b"f" b"b31" not in edited.lower():
        return edited
    extra = [(offset, category) for offset, category in audit.login_locations(edited)
             if category == "other"]
    for offset, _ in reversed(extra):
        edited = edited[:offset] + b"<USER>" + edited[offset + 4:]
    return edited


def split_commit(data):
    headers, message = data.split(b"\n\n", 1)
    fields = headers.splitlines()
    tree = fields[0].split()[1]
    parents = tuple(line[7:] for line in fields if line.startswith(b"parent "))
    identity = tuple(line for line in fields if line.startswith((b"author ", b"committer ", b"encoding ")))
    return tree, parents, identity, message


def archive_ids(paths):
    ids = set().union(*(ids for path, ids in paths.items() if ARCHIVES.fullmatch(path)))
    if len(ids) != 3:
        raise ValueError(f"expected the three approved archive blobs, found {len(ids)}")
    return ids


def note(original_digest):
    return (b"paths generalized for publication; the original sealed bytes are kept "
            b"in the private record, hash " + original_digest + b"\n")


def signature(entries):
    state = sha256()
    for path, entry in sorted(entries.items()):
        state.update(b" ".join(entry) + b"\t" + path + b"\0")
    return state.hexdigest()


def offline_manifest(path):
    return path.lower() == OFFLINE.lower()


def munich_missing_log(path, target):
    return (b"results_pmala_k2/SHA256SUMS.outputs" in path
            and posixpath.basename(target) == b"run.log")


class Build:
    def __init__(self, input_repo, target_repo, evidence, stripped, archives, protected, get):
        self.input = input_repo
        self.target = target_repo
        self.evidence = evidence
        self.stripped = stripped
        self.archives = archives
        self.protected = protected
        self.get = get
        self.digest_written = {}
        self.record = set()
        self.unresolved = set()
        self.baseline_mismatches = set()
        self.archived_manifest_targets = set()
        self.spod = (evidence / "spod.csv").read_bytes()
        self.data_doc = (HERE / "SPOD_DATA.md").read_bytes()

    @lru_cache(maxsize=None)
    def digest(self, oid):
        return sha256(self.get(oid)).hexdigest().encode()

    @lru_cache(maxsize=4096)
    def write(self, data):
        result = subprocess.check_output(
            ["git", "-C", str(self.target), "hash-object", "-w", "--stdin"], input=data
        )
        oid = result.strip()
        digest = sha256(data).hexdigest().encode()
        self.digest_written[oid] = digest
        return oid

    @lru_cache(maxsize=None)
    def sanitized(self, oid):
        data = self.get(oid)
        if b"\0" in data[:8192] or data.startswith(b"%PDF-"):
            return oid
        changed = edit_text(data)
        return self.write(changed) if changed != data else oid

    def new_digest(self, oid):
        return self.digest_written[oid] if oid in self.digest_written else self.digest(oid)

    def snapshot(self, tree, is_tip):
        original = dict(audit.tree_entries(tree, self.input))
        public = {}
        removed_archives = {}
        manifests = {}
        for path, (mode, kind, oid) in original.items():
            if oid in self.archives:
                label = posixpath.basename(path)
                pointer = path + NOTE_SUFFIX
                body = (b"Archive: " + label + b"\n\nSHA-256: " + self.digest(oid)
                        + b"\n\nHeld in the private record.\n")
                if pointer in original:
                    raise ValueError(f"archive pointer collides at {private_name(pointer)}")
                public[pointer] = (b"100644", b"blob", self.write(body))
                removed_archives[path] = pointer
                self.record.add((path, self.digest(oid), pointer, self.new_digest(public[pointer][2])))
                continue
            if oid in self.stripped or any(rule.search(path) for rule in DROP):
                continue
            if audit.hits(path, PATTERNS) or any(c == "other" for _, c in audit.login_locations(path)):
                raise ValueError(f"private filename needs a reviewed rename: {private_name(path)}")
            if kind == b"blob" and audit.manifest(path):
                manifests[path] = (mode, kind, oid)
            new = (oid if kind != b"blob" or path in audit.OWNER_PDF or path in manifests
                   else self.sanitized(oid))
            public[path] = (mode, kind, new)

        if is_tip:
            for path, data in ((SPOD_CSV, self.spod), (SPOD_DIR + b"DATA.md", self.data_doc)):
                public[path] = (b"100644", b"blob", self.write(data))
            ignore = b".gitignore"
            raw_ignore = b"/applications/Air Quality/S08_*.csv"
            content = (self.get(original[ignore][2]) if ignore in original else b"")
            content = edit_text(content)
            if raw_ignore not in content.splitlines():
                content = content.rstrip(b"\n") + b"\n" + raw_ignore + b"\n"
            public[ignore] = (b"100644", b"blob", self.write(content))

        for path in sorted(manifests):
            if not offline_manifest(path):
                continue
            readme = posixpath.join(posixpath.dirname(path), b"README.md")
            body = edit_text(self.get(original[readme][2])) if readme in original else b""
            if OFFLINE_NOTE.rstrip() not in body.splitlines():
                body = (body.rstrip(b"\n") + b"\n\n" if body else b"") + OFFLINE_NOTE
            public[readme] = (b"100644", b"blob", self.write(body))

        def resolve(path, target, expected):
            choices = [candidate for candidate in audit.checksum_aliases(path, target)
                       if candidate != path and candidate in original and original[candidate][1] == b"blob"]
            for candidate in dict.fromkeys(choices):
                if self.digest(original[candidate][2]) == expected:
                    return candidate
            if choices and not offline_manifest(path) and not munich_missing_log(path, target):
                self.baseline_mismatches.add((tree, path, target, expected))
                return choices[0]
            return None

        visiting = set()
        finished = set()

        def reseal(path):
            if path in finished:
                return
            if path in visiting:
                raise ValueError(f"cyclic manifest dependency: {private_name(path)}")
            visiting.add(path)
            mode, kind, oid = manifests[path]
            data = self.get(oid)
            rows = []
            for line in data.splitlines(keepends=True):
                entry = audit.MANIFEST_ENTRY.fullmatch(line.rstrip(b"\r\n"))
                if not entry:
                    if line.strip() and not line.startswith(b"#"):
                        raise ValueError(f"unsupported manifest record: {private_name(path)}")
                    rows.append(edit_text(line))
                    continue
                expected, target = entry.groups()
                candidate = resolve(path, target, expected.lower())
                actual_path = removed_archives.get(candidate, candidate)
                if actual_path not in public:
                    if offline_manifest(path):
                        rows.append(edit_text(line))
                        continue
                    if candidate is None and not munich_missing_log(path, target):
                        self.unresolved.add((tree, path, target))
                        if is_tip:
                            raise ValueError(f"unresolved release manifest target in {private_name(path)}: {private_name(target)}")
                    reason = b"omitted from the public repository" if candidate else b"offline or historically unavailable"
                    self.archived_manifest_targets.add((tree, path, target, reason))
                    rows.append(b"# " + reason + b": " + edit_text(line))
                    continue
                if actual_path in manifests:
                    reseal(actual_path)
                target_digest = self.new_digest(public[actual_path][2])
                relative = posixpath.relpath(actual_path, posixpath.dirname(path) or b".")
                if target_digest == expected and relative == target:
                    rows.append(line)
                else:
                    marker = line[64:66]
                    ending = b"\r\n" if line.endswith(b"\r\n") else b"\n" if line.endswith(b"\n") else b""
                    rows.append(target_digest + marker + relative + ending)
            edited = b"".join(rows)
            if edited != data:
                public[path] = (mode, kind, self.write(edited))
            visiting.remove(path)
            finished.add(path)

        for path in sorted(manifests):
            reseal(path)

        for path, (_, kind, oid) in list(public.items()):
            old = original.get(path)
            if old is None or kind != b"blob" or old[1] != b"blob" or old[2] == oid:
                continue
            if path in self.protected:
                pointer = path + NOTE_SUFFIX
                if pointer in public:
                    raise ValueError(f"publication note collides at {private_name(pointer)}")
                public[pointer] = (b"100644", b"blob", self.write(note(self.digest(old[2]))))
                self.record.add((path, self.digest(old[2]), path, self.new_digest(oid)))
        return public

    def prepare(self, tip):
        expected = self.evidence / "trees.tsv"
        # Filter-repo consumes raw object IDs already written to the isolated clone.
        # Store full snapshots once per distinct original tree, including a tip overlay.
        with expected.open("w") as report, audit.blobs(self.input, b"commit") as get_commit:
            cache = {}
            observed = []
            for oid in audit.git("rev-list", "--topo-order", "--reverse", "--all", repo=self.input).split():
                tree, _, _, message = split_commit(get_commit(oid))
                edited = edit_message(message)
                if edited != message:
                    observed.append(sha256(message).hexdigest().encode())
                if audit.hits(edited, PATTERNS) or any(
                    category == "other" for _, category in audit.login_locations(edited)
                ):
                    raise ValueError(f"unresolved commit message patterns in {oid.decode()}")
                key = (tree, oid == tip)
                if key not in cache:
                    public = self.snapshot(*key)
                    snapshot = self.evidence / "trees" / (tree.decode() + ("-tip" if key[1] else ""))
                    snapshot.write_bytes(b"".join(
                        b" ".join(entry) + b"\t" + path + b"\0" for path, entry in sorted(public.items())
                    ))
                    cache[key] = snapshot.name, signature(public)
                print(oid.decode(), *cache[key], sep="\t", file=report)
            if len(observed) != 11 or set(observed) != APPROVED_MESSAGES:
                raise ValueError("the pinned lineage must contain the eleven distinct approved messages")
        for filename, rows in (
            ("resealed_digests.tsv", self.record),
            ("historical_unresolved.tsv", self.unresolved),
            ("historical_checksum_differences.tsv", self.baseline_mismatches),
            ("archived_manifest_targets.tsv", self.archived_manifest_targets),
        ):
            with (self.evidence / filename).open("w", newline="") as stream:
                table = csv.writer(stream, delimiter="\t")
                for row in sorted(rows):
                    table.writerow([private_name(field) for field in row])


def stage_spod(input_repo, evidence, histories):
    tip_files = dict(audit.tree_entries(b"HEAD", input_repo))
    with audit.blobs(input_repo) as get:
        if SPOD_CSV in tip_files:
            data = get(tip_files[SPOD_CSV][2])
        else:
            stage = evidence / "spod-source"
            stage.mkdir()
            for filename in ("e18_prepare_spod.R", "e18_common.R"):
                path = b"engineering/E18_Air_Refit/" + filename.encode()
                target = stage / os.fsdecode(path)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(get(tip_files[path][2]))
            candidates = histories.get(SPOD_DIR + RAW_NAME, set()) | histories.get(
                b"Data Applications/Air Quality/" + RAW_NAME, set()
            )
            for oid in sorted(candidates):
                raw = get(oid)
                if sha256(raw).hexdigest() == RAW_SHA:
                    break
            else:
                raise ValueError("the pinned E-18 raw input is absent")
            target = stage / os.fsdecode(SPOD_DIR + RAW_NAME)
            target.parent.mkdir(parents=True)
            target.write_bytes(raw)
            rds = stage / "spod.rds"
            csv_path = stage / "spod.csv"
            with (evidence / "spod-preparation.log").open("wb") as log:
                subprocess.run(["Rscript", "--vanilla", "engineering/E18_Air_Refit/e18_prepare_spod.R", rds],
                               cwd=stage, stdout=log, stderr=subprocess.STDOUT, check=True)
                if sha256(rds.read_bytes()).hexdigest() != RDS_SHA:
                    raise ValueError("prepared SPod RDS differs from the pin")
                subprocess.run(["Rscript", "--vanilla", HERE / "export_spod.R", rds, csv_path],
                               cwd=stage, stdout=log, stderr=subprocess.STDOUT, check=True)
            data = csv_path.read_bytes()
            # The private input stays in the private repo. Keep only clean build evidence.
            target.unlink()
            rds.unlink()
        if sha256(data).hexdigest() != CSV_SHA:
            raise ValueError("public SPod CSV differs from the pin")
        (evidence / "spod.csv").write_bytes(data)


@lru_cache(maxsize=1)
def callback_index():
    work = Path(os.environ["BQTF_BUILD_EVIDENCE"])
    return work / "trees", {
        oid.encode(): filename for oid, filename, _ in
        (line.split("\t") for line in (work / "trees.tsv").read_text().splitlines())
    }


def callback_commit(commit):
    from git_filter_repo import FileChange

    trees, index = callback_index()
    changes = [FileChange(b"DELETEALL")]
    for record in (trees / index[commit.original_id]).read_bytes().split(b"\0"):
        if record:
            meta, path = record.split(b"\t", 1)
            mode, _, oid = meta.split()
            changes.append(FileChange(b"M", path, oid, mode))
    commit.file_changes = changes


def read_mapping(path):
    return dict(line.split() for line in path.read_bytes().splitlines()[1:])


def verify(input_repo, public, evidence):
    mapping = read_mapping(evidence / "hash_map.tsv")
    expected = {
        oid.encode(): digest for oid, _, digest in
        (line.split("\t") for line in (evidence / "trees.tsv").read_text().splitlines())
    }
    if mapping.keys() != expected.keys() or set(mapping.values()) != set(
        audit.git("rev-list", "--all", repo=public).split()
    ):
        raise ValueError("the commit map does not cover the pinned and public histories")
    counts = {"commits": 0, "messages changed": 0, "author files": 0,
              "historical local checksum checks": 0}
    verified_trees = set()
    recorded_digests = {}
    recorded_manifests = {}
    with (
        audit.blobs(input_repo, b"commit") as before,
        audit.blobs(public, b"commit") as after,
        audit.blobs(input_repo) as old_blob,
        audit.blobs(public) as new_blob,
    ):
        for old, new in mapping.items():
            old_tree, parents, identity, message = split_commit(before(old))
            tree, new_parents, new_identity, new_message = split_commit(after(new))
            if (new_parents != tuple(mapping[parent] for parent in parents)
                    or identity != new_identity or new_message != edit_message(message)):
                raise ValueError(f"unexpected history or metadata change at {old.decode()}")
            counts["messages changed"] += new_message != message
            actual = dict(audit.tree_entries(tree, public))
            if signature(actual) != expected[old]:
                raise ValueError(f"unexpected public tree at {new.decode()}")
            if tree not in verified_trees:
                for path, (_, kind, oid) in actual.items():
                    if kind != b"blob" or not audit.manifest(path):
                        continue
                    if oid not in recorded_manifests:
                        recorded_manifests[oid] = audit.manifest_entries(new_blob(oid))
                    for digest, target in recorded_manifests[oid]:
                        resolved = posixpath.normpath(posixpath.join(posixpath.dirname(path), target))
                        entry = actual.get(resolved)
                        if entry is None and offline_manifest(path):
                            continue
                        if target.startswith(b"/") or entry is None or entry[1] != b"blob":
                            raise ValueError(f"unresolved historical public checksum in {private_name(path)}")
                        target_oid = entry[2]
                        if target_oid not in recorded_digests:
                            recorded_digests[target_oid] = sha256(new_blob(target_oid)).hexdigest().encode()
                        if recorded_digests[target_oid] != digest.lower():
                            raise ValueError(f"historical public checksum mismatch in {private_name(path)}")
                        counts["historical local checksum checks"] += 1
                verified_trees.add(tree)
            original = dict(audit.tree_entries(old_tree, input_repo))
            for path in audit.AUTHOR_FILES & original.keys():
                if path not in actual or EMAIL.findall(old_blob(original[path][2])) != EMAIL.findall(new_blob(actual[path][2])):
                    raise ValueError(f"author address changed in {private_name(path)}")
                counts["author files"] += 1
            counts["commits"] += 1
    if counts["messages changed"] != 11:
        raise ValueError("wrong number of changed commit messages")
    forbidden = set((evidence / "forbidden-objects.txt").read_bytes().split())
    reachable = set(audit.git("rev-list", "--all", "--objects", "--no-object-names", repo=public).split())
    if reachable & forbidden:
        raise ValueError("a removed blob is still reachable via another path")
    print(*(f"{key}: {value}" for key, value in counts.items()), sep="\n")


def gate(report, scan, checksums):
    summary = {}
    for line in report.read_text().splitlines():
        key, value = line.rsplit(": ", 1)
        summary[key] = int(value)
    blockers = ("raw_matches", "decoded_matches", "secret_marker_blobs", "container_decode_errors")
    if any(summary.get(key, 0) for key in blockers):
        raise ValueError("publication audit has residual patterns, credential markers or decode failures")
    with (scan / "login.tsv").open() as source:
        if any(int(row["other login"]) for row in csv.DictReader(source, delimiter="\t")):
            raise ValueError("non-author login occurrences remain")
    with checksums.open() as source:
        manifest_rows = list(csv.DictReader(source, delimiter="\t"))
    for row in manifest_rows:
        offline = offline_manifest(os.fsencode(row["manifest"]))
        if int(row["mismatch"]) or int(row["unsupported lines"]) or (int(row["missing"]) and not offline):
            raise ValueError(f"unverified public manifest: {row['manifest']}")
    if not any(row["manifest"] == "lean/SHA256SUMS.txt" and int(row["ok"]) == 58 for row in manifest_rows):
        raise ValueError("expected the 58 Lean checksums")
    if len((scan / "path-hits.tsv").read_text().splitlines()) > 1:
        raise ValueError("matching public filenames remain")


def main():
    command, *args = sys.argv[1:]
    if command == "prepare":
        input_repo, target, evidence, protected, strip = map(Path, args)
        tip = audit.git("rev-parse", "HEAD", repo=input_repo).strip()
        stripped = set(strip.read_bytes().split())
        if len(stripped) != 17:
            raise ValueError("expected five unreadable PDFs and twelve E-03 blob IDs")
        paths = audit.all_paths(input_repo)
        archive_blobs = archive_ids(paths)
        forbidden = stripped | archive_blobs
        # Path filtering covers known aliases. Treat duplicate bytes as forbidden too.
        for path, oids in paths.items():
            if any(rule.search(path) for rule in DROP) and not path.startswith(
                (b"engineering/H_RW/", b"Engineering/H_RW/")
            ):
                forbidden.update(oids)
        (evidence / "forbidden-objects.txt").write_bytes(b"\n".join(sorted(forbidden)) + b"\n")
        (evidence / "trees").mkdir()
        stage_spod(input_repo, evidence, paths)
        with audit.blobs(input_repo) as get:
            build = Build(input_repo, target, evidence, forbidden - archive_blobs, archive_blobs,
                          set(protected.read_bytes().split(b"\0")), get)
            build.prepare(tip)
    elif command == "verify":
        verify(*map(Path, args))
    elif command == "gate":
        gate(*map(Path, args))
    else:
        raise ValueError("unknown public build step")


if __name__ == "__main__":
    main()
