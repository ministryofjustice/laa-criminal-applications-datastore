#!/bin/bash
#
# Execute commands when LocalStack becomes ready to pre-seed it
# with custom state, like having a certain S3 bucket, etc.
# You can use anything available inside the container.
# This file will be mounted through `docker-compose`.
#
ENDPOINT="https://localhost.localstack.cloud:4566"
BUCKET_NAME="crime-apply-documents-dev"
SNS_TOPIC_NAME="events-sns-topic-dev"
SQS_DLQ_NAME="events-sqs-dlq-dev"
SQS_QUEUE_NAME="events-sqs-queue-dev"
# This is the Review endpoint where notifications are sent
SNS_NOTIFICATION_ENDPOINT="http://host.docker.internal:3001/api/events"

echo
echo "Creating local S3 bucket..."
aws s3api create-bucket --bucket $BUCKET_NAME --endpoint-url=$ENDPOINT > /dev/null

echo "Creating local SNS topic..."
SNS_TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_NAME --endpoint-url=$ENDPOINT --output text --query 'TopicArn')

echo "Creating local SQS dead letter queue..."
SQS_DLQ_URL=$(aws sqs create-queue --queue-name $SQS_DLQ_NAME --endpoint-url=$ENDPOINT --output text --query 'QueueUrl')
SQS_DLQ_ARN=$(aws sqs get-queue-attributes --queue-url $SQS_DLQ_URL --endpoint-url=$ENDPOINT --attribute-names 'QueueArn' --output text --query 'Attributes.QueueArn')

echo "Creating local SQS queue..."
SQS_QUEUE_URL=$(aws sqs create-queue --queue-name $SQS_QUEUE_NAME --endpoint-url=$ENDPOINT --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"'$SQS_DLQ_ARN'\",\"maxReceiveCount\": \"1\"}", "MessageRetentionPeriod": "1209600"}' --output text --query 'QueueUrl')
SQS_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $SQS_QUEUE_URL --endpoint-url=$ENDPOINT --attribute-names 'QueueArn' --output text --query 'Attributes.QueueArn')

echo "Subscribing SQS queue to SNS topic..."
aws sns subscribe \
    --topic-arn "$SNS_TOPIC_ARN" --endpoint-url "$ENDPOINT" \
    --protocol sqs --notification-endpoint "$SQS_QUEUE_ARN" \
    --attributes '{"FilterPolicy":"{\"event_name\":[\"apply.submission\", \"Applying::Archived\", \"Deleting::SoftDeleted\"]}"}' > /dev/null

echo
echo "[-- Local development configuration --]"
echo
echo "Use the following details when mocking AWS services with LocalStack."
echo "The '.env.development' file should already take care of this by default."
echo
echo "  Endpoint: $ENDPOINT"
echo "  Access Key ID: test"
echo "  Secret Access Key: test"
echo "  Region: $AWS_REGION"
echo
echo "In addition, depending which services you want, declare the following"
echo "variables in your '.env.development.local' file. Undeclare the SNS topic"
echo "to disable the publishing of SNS events."
echo
echo "  EVENTS_SNS_TOPIC_ARN=$SNS_TOPIC_ARN"
echo "  S3_BUCKET_NAME=$BUCKET_NAME"
echo
echo "Declare the following in Review to start polling messages:"
echo
echo "  AWS_REGION=us-east-1"
echo "  AWS_ACCESS_KEY_ID=test"
echo "  AWS_SECRET_ACCESS_KEY=test"
echo "  SQS_QUEUE_URL=$SQS_QUEUE_URL"
echo
