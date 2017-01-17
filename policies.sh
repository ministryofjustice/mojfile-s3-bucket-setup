set_bucket_policy() {
  local readonly bucket=$1
  local readonly upload_user=$2
  local readonly download_user=$3
  local readonly policy_template=$4
  local readonly aws_region=$5
  add_bucket_policy ${bucket} ${upload_user} ${download_user} ${policy_template} ${aws_region}
}

add_bucket_policy() {
  export bucket=$1
  local readonly upload_user=$2
  local readonly download_user=$3
  local readonly policy_template=$4
  local readonly aws_region=$5

  export upload_user_arn=$(get_user_arn ${upload_user} ${aws_region})
  export download_user_arn=$(get_user_arn ${download_user} ${aws_region})

  echo "Applying bucket security policy to ${bucket}"
  cat ${policy_template} | envsubst > /tmp/policy.json

  aws s3api put-bucket-policy --bucket ${bucket} --region ${aws_region} --policy file:///tmp/policy.json
}
