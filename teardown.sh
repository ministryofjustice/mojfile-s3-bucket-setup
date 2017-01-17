#!/bin/bash

source ./shared.sh
source ./buckets.sh
source ./users.sh

main() {
  check_prerequisites
  delete_bucket ${BUCKET}
  delete_bucket ${USER_BUCKET}
  teardown_user ${UPLOAD_IAM_USER}
  teardown_user ${DOWNLOAD_IAM_USER}
  echo "Finished"
}

main
