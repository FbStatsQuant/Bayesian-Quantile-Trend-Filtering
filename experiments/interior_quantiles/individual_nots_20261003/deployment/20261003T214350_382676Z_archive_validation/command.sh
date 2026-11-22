#!/bin/bash
set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
tar -czf deployment/validation_1785936.tar.gz validation/check_20261003T213509Z_1785936 validate_1785936.out validate_1785936.err
sha256sum deployment/validation_1785936.tar.gz > deployment/validation_1785936.tar.gz.sha256
cat deployment/validation_1785936.tar.gz.sha256
