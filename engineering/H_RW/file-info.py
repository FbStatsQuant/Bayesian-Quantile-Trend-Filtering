# Body for git-filter-repo --file-info-callback. Gitlinks have no blob body.
import os

if "protected" not in value.data:
    with open(os.environ["BQTF_PROTECTED_PATHS"], "rb") as source:
        value.data["protected"] = set(source.read().split(b"\0"))
    value.data["rewritten"] = {}
if filename in value.data["protected"] or mode == b"160000":
    return filename, mode, blob_id
# Cache only after the path test. The same blob can occur at a protected alias.
cache = value.data["rewritten"]
if blob_id not in cache:
    contents = value.get_contents_by_identifier(blob_id)
    result = blob_id
    if not value.is_binary(contents) and not contents.startswith(b"%PDF-"):
        edited = value.apply_replace_text(contents)
        if edited != contents:
            result = value.insert_file_with_contents(edited)
    cache[blob_id] = result
return filename, mode, cache[blob_id]
