# Shared environment variables and functions for S3 bucket setup/teardown

BUCKET=${BUCKET:-dstestbucket-20160912}
UPLOAD_IAM_USER=${UPLOAD_IAM_USER:-dstestupuser-20160912}
DOWNLOAD_IAM_USER=${DOWNLOAD_IAM_USER:-dstestdownuser-20160912}

REGION=${REGION:-eu-west-1}

POLICY_TEMPLATE=${POLICY_TEMPLATE:-s3-policy.json.template}
DOWNLOAD_POLICY_TEMPLATE=${DOWNLOAD_POLICY_TEMPLATE:-download-policy.json.template}

UPLOAD_CREDS_FILE=upload-credentials.json
DOWNLOAD_CREDS_FILE=download-credentials.json

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
  local readonly creds_file=$3

  if bucket_exists ${bucket} ${creds_file}; then
    echo "Bucket ${bucket} already exists"
  else
    echo "Creating bucket: ${bucket}"
    aws s3 mb s3://${bucket} --region ${aws_region}
  fi
}

bucket_exists() {
  local readonly bucket=$1
  local readonly creds_file=$2

  if [[ ! -f ${creds_file} ]]; then
    return 1
  fi

  local readonly access_key=$(get_access_key ${creds_file})
  local readonly secret_key=$(get_secret_key ${creds_file})

  # return 0 for success, 1 for failure, so we can use this function in if statements
  s3cmd --access_key=$access_key --secret_key=$secret_key ls s3://dstestbucket-20160912 && return 0
  return 1
}

get_username() {
  local readonly creds_file=$1
  echo $(cat ${creds_file} | jq -r '.AccessKey.UserName')
}

get_access_key() {
  local readonly creds_file=$1
  echo $(cat ${creds_file} | jq -r '.AccessKey.AccessKeyId')
}

get_secret_key() {
  local readonly creds_file=$1
  echo $(cat ${creds_file} | jq -r '.AccessKey.SecretAccessKey')
}

set_bucket_policy() {
  local readonly bucket=$1
  local readonly upload_user=$2
  local readonly download_user=$3
  local readonly policy_template=$4
  local readonly aws_region=$5

  create_user ${upload_user} ${aws_region}
  create_user ${download_user} ${aws_region}
  sleep_for 15 # without this, we get "An error occurred (MalformedPolicy) when calling the PutBucketPolicy operation: Invalid principal in policy"
  # TODO: replace this sleep with a loop that waits until the user information can be retrieved
  add_bucket_policy ${bucket} ${upload_user} ${download_user} ${policy_template} ${aws_region}
}

create_user() {
  local readonly user=$1
  local readonly aws_region=$2

  echo "Creating IAM user: ${user}"
  aws iam create-user --user-name ${user} --region ${aws_region}
}

add_bucket_policy() {
  export bucket=$1
  local readonly upload_user=$2
  local readonly download_user=$3
  local readonly policy_template=$4
  local readonly aws_region=$5

  export upload_user_arn=$(get_user_arn ${upload_user} ${aws_region})
  export download_user_arn=$(get_user_arn ${download_user} ${aws_region})

  echo "Applying bucket policy"
  cat ${policy_template} | envsubst > /tmp/policy.json
  aws s3api put-bucket-policy --bucket ${bucket} --region ${aws_region} --policy file:///tmp/policy.json
}

output_credentials() {
  local readonly user=$1
  local readonly aws_region=$2
  local readonly creds_file=$3

  echo "\nAWS USER CREDENTIALS....................."
  aws iam create-access-key --user-name ${user} --region ${aws_region} | tee ${creds_file}
  echo "THESE ARE NOW STORED IN THE FILE: ${creds_file}"
  echo "PLEASE TAKE APPROPRIATE PRECAUTIONS TO SECURE THESE."
}

get_user_arn() {
  local readonly user=$1
  local readonly aws_region=$2

  aws iam get-user --user-name ${user} --region ${aws_region} | jq -r '.User.Arn'
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

