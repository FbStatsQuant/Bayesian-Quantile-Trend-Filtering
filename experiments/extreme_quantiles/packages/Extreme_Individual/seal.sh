#!/bin/bash
# Writes SHA256SUMS in Extreme_Individual, Extreme_admm and Extreme_Onizuka (excluding runs/ and validation/).
# Any later edit invalidates the validation approval; re-seal and re-validate after editing.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
base=$(dirname "$package")
for d in Extreme_Individual Extreme_admm Extreme_Onizuka; do
  (cd "$base/$d" && find . -type f ! -name SHA256SUMS ! -path './runs/*' ! -path './validation/*' -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS)
done
(cd "$base" && cat Extreme_Individual/SHA256SUMS Extreme_admm/SHA256SUMS Extreme_Onizuka/SHA256SUMS | sha256sum | cut -d' ' -f1)
