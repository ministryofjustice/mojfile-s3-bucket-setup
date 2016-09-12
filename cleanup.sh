#!/bin/bash

source ./shared.sh

main() {
  local readonly access_key=$(cat ${UPLOAD_CREDS_FILE} | jq -r '.AccessKey.AccessKeyId')

  delete_bucket ${BUCKET} ${REGION}
  # You must delete the user's credentials before you can delete the user
  delete_user_credentials ${IAM_USER} ${access_key} ${REGION}
  delete_user ${IAM_USER} ${REGION}
  remove_credentials_file ${UPLOAD_CREDS_FILE}
  echo "Finished"
}

delete_bucket() {
  local readonly s3_bucket=$1
  local readonly aws_region=$2

  echo "Delete bucket ${s3_bucket}............"

  aws s3 rb s3://${s3_bucket} --region ${aws_region}
}

delete_user_credentials() {
  local readonly user=$1
  local readonly access_key=$2
  local readonly aws_region=$3

  echo "Delete user credentials ${access_key}............."

  aws iam delete-access-key --user-name ${user} --access-key-id ${access_key} --region ${aws_region}
}

delete_user() {
  local readonly user=$1
  local readonly aws_region=$2

  echo "Delete user ${user}............."

  aws iam delete-user --user-name ${user} --region ${aws_region}
}

remove_credentials_file() {
  local readonly creds_file=$1

  echo "Remove credentials file ${creds_file}........"
  rm ${creds_file}
}

main
