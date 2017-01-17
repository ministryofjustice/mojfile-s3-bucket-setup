delete_bucket() {
  local readonly bucket=$1

  if bucket_exists ${bucket}; then
    echo "Delete bucket ${bucket}............"
    aws s3api delete-bucket --bucket ${bucket}
  else
    echo "Bucket ${bucket} already deleted"
  fi
}

make_bucket() {
  local readonly bucket=$1
  local readonly aws_region=$2

  if bucket_exists ${bucket}; then
    echo "Bucket ${bucket} already exists"
  else
    echo "Creating bucket: ${bucket}"
    aws s3 mb s3://${bucket} --region ${aws_region} 2>&1 > /dev/null
  fi
}

bucket_exists() {
  local readonly bucket=$1

  # return 0 if the bucket exists, 1 if it does.
  aws s3api list-buckets | jq -r ' .Buckets[] | (.Name)' | grep -q ${bucket} && return 0
  return 1
}
