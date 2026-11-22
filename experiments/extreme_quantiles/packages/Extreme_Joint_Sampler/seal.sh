#!/bin/bash
# Writes SHA256SUMS for this folder (excluding runs/ and validation/). Re-seal and re-validate after any edit.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
cd "$package"
find . -type f ! -name SHA256SUMS ! -path './runs/*' ! -path './validation/*' -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
sha256sum SHA256SUMS | cut -d' ' -f1
