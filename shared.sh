# Shared environment variables and functions for S3 bucket setup/teardown

REVISION=${REVISION:-$(git rev-parse --short @)}
BUCKET=${BUCKET:-tax-tribunals-downloader-test-${REVISION}}
USER_BUCKET=${USER_BUCKET:-tax-tribunals-downloader-user-sessions-test-${REVISION}}
REGION=${REGION:-eu-west-1}
POLICY_TEMPLATE=${POLICY_TEMPLATE:-s3-policy.json.template}

LIFECYCLE_POLICY=${LIFECYCLE_POLICY:-lifecycle.json}
USER_BUCKET_LIFECYCLE_POLICY=${USER_BUCKET_LIFECYCLE_POLICY:-user-bucket-lifecycle.json}

UPLOAD_IAM_USER=${UPLOAD_IAM_USER:-tax-tribunals-downloader-test-upload-user-${REVISION}}
UPLOAD_CREDS_FILE=upload-credentials.json
DOWNLOAD_IAM_USER=${DOWNLOAD_IAM_USER:-tax-tribunals-downloader-test-download-user-${REVISION}}
DOWNLOAD_CREDS_FILE=download-credentials.json

check_prerequisites() {
  for program in jq aws envsubst; do
    if ! is_installed ${program}; then
      die_with_message "FAILURE: ${program} is not installed. Exiting."
    fi
  done

  if ! validate_aws_credentials; then
    die_with_message "FAILURE: Valid AWS credentials are not configured. Exiting."
  fi

  if [ ! -f ${POLICY_TEMPLATE} ]; then
    die_with_message "FAILURE: ${POLICY_TEMPLATE} not found. Exiting."
  fi
}

is_installed() {
  local readonly program=$1

  if [ $(which ${program}) ]; then
    return 0 # success
  else
    return 1 # failure
  fi
}

validate_aws_credentials() {
  aws iam get-user --region=${REGION} >/dev/null && return 0 # success
  return 1 # failure
}

die_with_message() {
  local readonly message=$1
  echo ${message}
  exit 1
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

output_credentials() {
  local readonly user=$1
  local readonly aws_region=$2
  local readonly creds_file=$3

  echo
  echo "AWS USER CREDENTIALS FOR ${user}:"
  echo "*** These DO NOT contain the AWS secret key. This will only be shown when you first create the key."
  aws iam list-access-keys --user-name ${user} | tee ${creds_file}
  echo "THESE ARE NOW STORED IN THE FILE: ${creds_file}"
  echo "PLEASE TAKE APPROPRIATE PRECAUTIONS TO SECURE THESE."
}
