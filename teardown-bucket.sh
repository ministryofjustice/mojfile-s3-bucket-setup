#!/bin/bash

source ./shared.sh

main() {
  delete_bucket ${BUCKET} ${REGION}
  teardown_user ${UPLOAD_CREDS_FILE}   ${REGION}
  teardown_user ${DOWNLOAD_CREDS_FILE} ${REGION}
  echo "Finished"
}

main
