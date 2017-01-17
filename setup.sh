#!/bin/bash

# This script sets up an S3 bucket for the file upload API.
# It creates an IAM user, an S3 bucket, and applies the appropriate
# security policy, such that the user can list, upload and delete files

# NB: permission to download objects from the bucket is deliberately ommitted,
# for security

set -euo pipefail

source ./shared.sh
source ./buckets.sh
source ./users.sh
source ./lifecycle.sh
source ./policies.sh

main() {
  check_prerequisites
  make_bucket ${BUCKET} ${REGION}
  make_bucket ${USER_BUCKET} ${REGION}
  create_user ${UPLOAD_IAM_USER} ${REGION}
  create_user ${DOWNLOAD_IAM_USER} ${REGION}
  create_access_key ${UPLOAD_IAM_USER}
  create_access_key ${DOWNLOAD_IAM_USER}
  set_bucket_policy ${BUCKET} ${UPLOAD_IAM_USER} ${DOWNLOAD_IAM_USER} ${POLICY_TEMPLATE} ${REGION}
  set_bucket_policy ${USER_BUCKET} ${UPLOAD_IAM_USER} ${DOWNLOAD_IAM_USER} ${POLICY_TEMPLATE} ${REGION}
  apply_lifecycle_policy ${BUCKET} ${REGION} ${LIFECYCLE_POLICY}
  apply_lifecycle_policy ${USER_BUCKET} ${REGION} ${USER_BUCKET_LIFECYCLE_POLICY}
  output_credentials ${UPLOAD_IAM_USER} ${REGION} ${UPLOAD_CREDS_FILE}
  output_credentials ${DOWNLOAD_IAM_USER} ${REGION} ${DOWNLOAD_CREDS_FILE}
  echo "Finished"
}

main
