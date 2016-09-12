#!/bin/bash

source ./shared.sh

main() {
  local readonly access_key=$(get_access_key ${UPLOAD_CREDS_FILE})

  delete_bucket ${BUCKET} ${REGION}
  # You must delete the user's credentials before you can delete the user
  delete_user_credentials ${IAM_USER} ${access_key} ${REGION}
  delete_user ${IAM_USER} ${REGION}
  remove_credentials_file ${UPLOAD_CREDS_FILE}
  echo "Finished"
}

main
