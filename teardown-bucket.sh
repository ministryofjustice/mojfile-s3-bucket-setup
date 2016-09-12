#!/bin/bash

source ./shared.sh

main() {
  delete_bucket ${BUCKET} ${REGION}
  teardown_user ${UPLOAD_CREDS_FILE}   ${REGION}
  teardown_user ${DOWNLOAD_CREDS_FILE} ${REGION}
  echo "Finished"
}

teardown_user() {
  local readonly creds_file=$1
  local readonly aws_region=$2

  local readonly user=$(get_username ${creds_file})
  local readonly access_key=$(get_access_key ${creds_file})

  # # You must delete the user's credentials before you can delete the user
  delete_user_credentials ${user} ${access_key} ${aws_region}
  delete_user ${user} ${aws_region}

  remove_credentials_file ${creds_file}
}

main
