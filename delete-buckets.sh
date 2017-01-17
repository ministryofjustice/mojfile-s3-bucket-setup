#!/bin/bash

set -euo pipefail

source ./shared.sh
source ./buckets.sh

main() {
  check_prerequisites
  delete_bucket ${BUCKET} ${REGION}
  delete_bucket ${USER_BUCKET} ${REGION}
  echo "Finished"
}

main
