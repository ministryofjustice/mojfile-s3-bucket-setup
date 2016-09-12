# Setup Amazon S3 for the File Upload API

Create an S3 bucket, IAM user and security policy for the file upload API.

## Pre-requisites
* AWS command-line tool, with valid credentials in ~/.aws/credentials
* jq command-line tool (so that the bash script can get values from JSON)
* envsubst - enables replacing env vars in templates with their values. Usually installed via the 'gettext' package (see http://stackoverflow.com/a/37192554/794111 if using homebrew on a mac)

## Setup
* Edit `setup.sh` to set the appropriate values
* Run `setup.sh`

After the script finishes, it will display the S3 credentials for your application, and will also record them in `credentials.json`

There is a race condition where the IAM user may not be available when we try to use it. The script has a sleep to try and mitigate this, but if you see the following error, this is what has happened;

    An error occurred (MalformedPolicy) when calling the PutBucketPolicy operation: Invalid principal in policy

In this case, run the `cleanup.sh` script and try again.

## Teardown
* Edit `cleanup.sh` to set the appropriate values for environment variables
* Run `cleanup.sh`

WARNING: This deletes the user, credentials and S3 bucket - ensure you really want this before running the script.

