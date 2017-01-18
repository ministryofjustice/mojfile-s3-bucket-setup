teardown_user() {
  local readonly user=$1

  if user_exists ${user}; then
    # You must delete the user's access keys before you can delete the user
    delete_access_keys ${user}
    delete_user ${user}
  else
    echo "User already deleted: ${user}"
  fi
}

delete_user() {
  local readonly user=$1
  echo "Delete user ${user}............."
  aws iam delete-user --user-name ${user}
}

delete_access_keys() {
  local readonly user=$1

  echo "Deleting access keys for user ${user}............."
  for access_key in $(aws iam list-access-keys --user ${user} |  jq -r '.AccessKeyMetadata[] | "\(.AccessKeyId)"'); do
    aws iam delete-access-key --user ${user} --access-key-id ${access_key}
  done
}

create_user() {
  local readonly user=$1
  local readonly region=$2

  if user_exists ${user}; then
    echo "User ${user} already exists"
  else
    echo "Creating IAM user: ${user}"
    aws iam create-user --user-name ${user} --region ${region} 2>&1 > /dev/null
  fi
}

create_access_key() {
  local readonly user=$1

  if access_key_exists ${user}; then
    echo "Access key for user ${user} already exists"
    echo "*** If you need new keys, you will either need to teardown and setup again, or add them manually."
  else
    echo "Creating access key for user: ${user}"
    echo
    echo
    echo "KEYS FOR ${user}............."
    echo "NOTE: This is the ONLY time you will see AWS_SECRET_ACCESS_KEY"
    echo "Use the following exports for access in your dev environment:"
    echo
    echo
    aws iam create-access-key --user-name ${user} |
      jq -r '"export AWS_SECRET_ACCESS_KEY=" + .AccessKey.SecretAccessKey, "export AWS_ACCESS_KEY_ID=" + .AccessKey.AccessKeyId'
    echo
    echo
  fi
}

access_key_exists() {
  local readonly user=$1

  # return 1 if access key does not exist, 0 if it does.
  aws iam list-access-keys --user ${user} 2> /dev/null | grep -q 'AccessKeyId' && return 0
  return 1
}

user_exists() {
  local readonly user=$1

  # return 0 if the user exists and 1 if they don't.
  aws iam get-user --user-name ${user} 2> /dev/null | grep -q 'UserName' && return 0
  return 1
}

get_user_arn() {
  local readonly user=$1
  local readonly aws_region=$2

  aws iam get-user --user-name ${user} --region ${aws_region} | jq -r '.User.Arn'
}

