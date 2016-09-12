# Shared environment variables and functions for S3 bucket setup/teardown

BUCKET=${BUCKET:-dstestbucket-20160912}
UPLOAD_IAM_USER=${UPLOAD_IAM_USER:-dstestuser-20160912}

REGION=${REGION:-eu-west-1}
UPLOAD_POLICY_TEMPLATE=${UPLOAD_POLICY_TEMPLATE:-upload-policy.json.template}

UPLOAD_CREDS_FILE=upload-credentials.json

get_access_key() {
  local readonly creds_file=$1
  echo $(cat ${creds_file} | jq -r '.AccessKey.AccessKeyId')
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

