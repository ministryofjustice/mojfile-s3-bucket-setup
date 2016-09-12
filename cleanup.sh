#!/bin/bash

source ./shared.sh

ACCESS_KEY_ID=AKIAJKWDW3X6IMA3B3TA

main() {
  aws s3 rb s3://${BUCKET} --region ${REGION}
  # You must delete the user's credentials before you can delete the user
  aws iam delete-access-key --user-name ${IAM_USER} --access-key-id ${ACCESS_KEY_ID} --region ${REGION}
  aws iam delete-user --user-name ${IAM_USER} --region ${REGION}
  rm credentials.json
  echo "Finished"
}

main
