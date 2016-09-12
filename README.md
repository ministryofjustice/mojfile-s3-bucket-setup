# Setup Amazon S3 for the File Upload & Download APIs

Create an S3 bucket, IAM users and security policy for the file [upload](https://github.com/ministryofjustice/s3-uploader-prototype/) and download APIs.

Although, in theory, the file upload and download APIs could be used separatedly, S3 only
allows a single security policy on an S3 bucket. So, this project assumes that both the
upload and the download components will be used, and sets up an S3 bucket and IAM users
accordingy.

A single S3 bucket is created, plus 2 IAM users (one for uploading, and another for
downloading). If you really only want either the upload or download component, edit
the setup/teardown scripts as required.

## Pre-requisites
* AWS command-line tool, with valid credentials in ~/.aws/credentials
* jq command-line tool (so that the bash script can get values from JSON)
* envsubst - enables replacing env vars in templates with their values. Usually installed via the 'gettext' package (see http://stackoverflow.com/a/37192554/794111 if using homebrew on a mac)

## Setup
* Edit `shared.sh` to set the appropriate values (unless you plan to override them on the command line)
* Run `./setup-bucket.sh` (overriding any environment variables, as you wish)

After the script finishes, it will display two sets of S3 credentials for your application, and will also record them in json files.

There is a race condition where the IAM user may not be available when we try to use it. The script has a sleep to try and mitigate this, but if you see the following error, this is what has happened;

    An error occurred (MalformedPolicy) when calling the PutBucketPolicy operation: Invalid principal in policy

In this case, run the `teardown-bucket.sh` script and try again.

## Teardown
* Edit `shared.sh` to set the appropriate values (unless you plan to override them on the command line)
* Run `teardown-bucket.sh` (overriding any environment variables, as you wish)

WARNING: This deletes the users, credentials and S3 bucket - ensure you really want this before running the script.

