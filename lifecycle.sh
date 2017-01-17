apply_lifecycle_policy() {
  local readonly bucket=$1
  local readonly aws_region=$2
  local readonly policy_file=$3

  if lifecycle_exists ${bucket}; then
    echo "Lifecycle for ${bucket} already exists"
  else
    echo "Applying lifecycle policy to : ${bucket}"
    aws --region=${aws_region} s3api put-bucket-lifecycle --bucket ${bucket} --lifecycle-configuration file://${policy_file}
  fi
}

lifecycle_exists() {
  local readonly bucket=$1

  # return 0 if lifecycle does not exist 1 if it does.
  aws s3api get-bucket-lifecycle --bucket ${bucket} 2>&1 | grep -q 'NoSuchLifecycleConfiguration' && return 0
  return 1
}

