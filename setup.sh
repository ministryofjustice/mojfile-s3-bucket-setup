#!/bin/bash

# This script sets up an S3 bucket for the file upload API.
# It creates an IAM user, an S3 bucket, and applies the appropriate
# security policy, such that the user can list files, upload files,
# and manage the files metadata.

set -euo pipefail

source ./shared.sh

main() {
  make_bucket ${BUCKET}
  set_bucket_policy ${BUCKET} ${IAM_USER}
  output_credentials ${IAM_USER}
  echo "Finished"
}

make_bucket() {
  local readonly bucket=$1
  echo "Creating bucket: ${bucket}"
  aws s3 mb s3://${bucket} --region ${REGION}
}

set_bucket_policy() {
  local readonly bucket=$1
  local readonly user=$2

  create_user ${user}
  sleep 15 # without this, we get "An error occurred (MalformedPolicy) when calling the PutBucketPolicy operation: Invalid principal in policy"
  # TODO: replace this sleep with a loop that waits until the user information can be retrieved
  add_bucket_policy ${bucket} ${user}
}

output_credentials() {
  local readonly user=$1
  echo "AWS USER CREDENTIALS....................."
  aws iam create-access-key --user-name ${user} --region ${REGION} | tee credentials.json
  echo "THESE ARE NOW STORED IN THE FILE: credentials.json IN THIS DIRECTORY"
  echo "PLEASE TAKE APPROPRIATE PRECAUTIONS TO SECURE THESE."
}

create_user() {
  local readonly user=$1
  echo "Creating IAM user: ${user}"
  aws iam create-user --user-name ${user} --region ${REGION}
}

add_bucket_policy() {
  export bucket=$1
  local readonly user=$2
  export user_arn=$(get_user_arn ${user})
  echo "Applying bucket policy"
  cat ${POLICY_TEMPLATE} | envsubst > /tmp/policy.json
  aws s3api put-bucket-policy --bucket ${bucket} --region ${REGION} --policy file:///tmp/policy.json
}

get_user_arn() {
  local readonly user=$1
  # Note, this echoes '"value"' not 'value' - i.e. including the double-quotes
  aws iam get-user --user-name ${user} --region ${REGION} | jq '.User.Arn'
}

main
