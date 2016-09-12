# Shared environment variables and functions for S3 bucket setup/teardown

BUCKET=${BUCKET:-dstestbucket-20160912}
IAM_USER=${IAM_USER:-dstestuser-20160912}

REGION=${REGION:-eu-west-1}
UPLOAD_POLICY_TEMPLATE=${UPLOAD_POLICY_TEMPLATE:-upload-policy.json.template}

UPLOAD_CREDS_FILE=upload-credentials.json

