# Shared environment variables and functions for S3 bucket setup/teardown

BUCKET=${BUCKET:-dstestbucket-20160830}
IAM_USER=${IAM_USER:-dstestuser-20160830}

REGION=${REGION:-eu-west-1}
POLICY_TEMPLATE=${POLICY_TEMPLATE:-upload-policy.json.template}
