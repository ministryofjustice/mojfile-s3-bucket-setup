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
  set_bucket_policy ${BUCKET} ${UPLOAD_IAM_USER} ${UPLOAD_POLICY_TEMPLATE} ${REGION}
  output_credentials ${UPLOAD_IAM_USER} ${REGION} ${UPLOAD_CREDS_FILE}
  echo "Finished"
}

main
