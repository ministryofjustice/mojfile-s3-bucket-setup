#!/bin/bash

# This script sets up an S3 bucket for the file upload API.
# It creates an IAM user, an S3 bucket, and applies the appropriate
# security policy, such that the user can list, upload and delete files

# NB: permission to read objects in the bucket is deliberately ommitted,
# for security

set -euo pipefail

source ./shared.sh

main() {
  make_bucket ${BUCKET} ${REGION}
  set_bucket_policy ${BUCKET} ${IAM_USER} ${UPLOAD_POLICY_TEMPLATE} ${REGION}
  output_credentials ${IAM_USER} ${REGION} ${UPLOAD_CREDS_FILE}
  echo "Finished"
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
  sleep 15 # without this, we get "An error occurred (MalformedPolicy) when calling the PutBucketPolicy operation: Invalid principal in policy"
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

  # Note, this echoes '"value"' not 'value' - i.e. including the double-quotes
  aws iam get-user --user-name ${user} --region ${aws_region} | jq '.User.Arn'
}

main
