set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
echo '5d0b8f202ff4791d02386864b2d0acb4afaa6a0cf9adf2bbab7b7854f95f4a8a  /home/fb31/projects/Quant_Reg/Inner_Individual/deployment/package_20261003T213406Z.tar.gz' | sha256sum --check
# Preserve every previous package before any deliberate redeployment.
if [[ -f SHA256SUMS ]]; then
  tar -czf deployment/previous_package_20261003T213406Z.tar.gz --files-from=<(sed 's/^[^ ]*  //' SHA256SUMS) SHA256SUMS
fi
tar -xzf /home/fb31/projects/Quant_Reg/Inner_Individual/deployment/package_20261003T213406Z.tar.gz
sha256sum --check SHA256SUMS
printf '%s\n' '5d0b8f202ff4791d02386864b2d0acb4afaa6a0cf9adf2bbab7b7854f95f4a8a' > deployment/package_20261003T213406Z.archive_sha256
date -u --iso-8601=seconds
