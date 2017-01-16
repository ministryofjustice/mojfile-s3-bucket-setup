#!/bin/bash

source ./shared.sh

main() {
  check_prerequisites
  delete_bucket ${BUCKET} ${REGION}
  delete_bucket ${BUCKET}-users ${REGION}
  teardown_user ${UPLOAD_CREDS_FILE}   ${REGION}
  teardown_user ${DOWNLOAD_CREDS_FILE} ${REGION}
  echo "Finished"
}

main
