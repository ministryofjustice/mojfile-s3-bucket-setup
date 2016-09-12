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

sleep_for() {
  local readonly seconds=${1:-10}

  echo "Sleeping for ${seconds} seconds"
  for i in $(seq 1 ${seconds}); do
    printf "."
    sleep 1
  done
  printf "\n"
}

make_bucket() {
  local readonly bucket=$1
  local readonly aws_region=$2

  echo "Creating bucket: ${bucket}"
  aws s3 mb s3://${bucket} --region ${aws_region}
}

set_bucket_policy() {
  local readonly bucket=$1
  local readonly user=$2
  local readonly policy_template=$3
  local readonly aws_region=$4

  create_user ${user} ${aws_region}
  sleep_for 15 # without this, we get "An error occurred (MalformedPolicy) when calling the PutBucketPolicy operation: Invalid principal in policy"
  # TODO: replace this sleep with a loop that waits until the user information can be retrieved
  add_bucket_policy ${bucket} ${user} ${policy_template} ${aws_region}
}

output_credentials() {
  local readonly user=$1
  local readonly aws_region=$2
  local readonly creds_file=$3

  echo "AWS USER CREDENTIALS....................."
  aws iam create-access-key --user-name ${user} --region ${aws_region} | tee ${creds_file}
  echo "THESE ARE NOW STORED IN THE FILE: ${creds_file}"
  echo "PLEASE TAKE APPROPRIATE PRECAUTIONS TO SECURE THESE."
}

create_user() {
  local readonly user=$1
  local readonly aws_region=$2

  echo "Creating IAM user: ${user}"
  aws iam create-user --user-name ${user} --region ${aws_region}
}

add_bucket_policy() {
  export bucket=$1
  local readonly user=$2
  local readonly policy_template=$3
  local readonly aws_region=$4

  export user_arn=$(get_user_arn ${user} ${aws_region})
  echo "Applying bucket policy"
  cat ${policy_template} | envsubst > /tmp/policy.json
  aws s3api put-bucket-policy --bucket ${bucket} --region ${aws_region} --policy file:///tmp/policy.json
}

get_user_arn() {
  local readonly user=$1
  local readonly aws_region=$2

  aws iam get-user --user-name ${user} --region ${aws_region} | jq -r '.User.Arn'
}

