#!/bin/bash
#
# Execute commands when LocalStack becomes ready to pre-seed it
# with custom state, like having a certain S3 bucket, etc.
# You can use anything available inside the container.
# This file will be mounted through `docker-compose`.
#
ENDPOINT="http://0.0.0.0:4566"
BUCKET_NAME="crime-apply-documents-dev"

echo "Creating local S3 bucket..."
aws s3api create-bucket --bucket $BUCKET_NAME --endpoint-url=$ENDPOINT

echo
echo "[-- Local development env configuration --]"
echo "By default these should already exist in your '.env.development' file."
echo
echo "S3_ACCESS_KEY_ID=test"
echo "S3_SECRET_ACCESS_KEY=test"
echo "S3_REGION=${AWS_REGION}"
echo "S3_BUCKET_NAME=$BUCKET_NAME"
echo "S3_LOCAL_ENDPOINT=$ENDPOINT"
echo
