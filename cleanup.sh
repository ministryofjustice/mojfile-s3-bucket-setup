#!/bin/bash

BUCKET_NAME=dstestbucket-20160830
IAM_USER_NAME=dstestuser-20160830
ACCESS_KEY_ID=AKIAJYPWSHPUWLED4W6Q

REGION=eu-west-1

main() {
  aws s3 rb s3://${BUCKET_NAME} --region ${REGION}
  # You must delete the user's credentials before you can delete the user
  aws iam delete-access-key --user-name ${IAM_USER_NAME} --access-key-id ${ACCESS_KEY_ID} --region ${REGION}
  aws iam delete-user --user-name ${IAM_USER_NAME} --region ${REGION}
  rm credentials.json
  echo "Finished"
}

main
