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
# This is the Review endpoint where notifications are sent
SNS_NOTIFICATION_ENDPOINT="http://host.docker.internal:3001/api/events"

echo
echo "Creating local S3 bucket..."
aws s3api create-bucket --bucket $BUCKET_NAME --endpoint-url=$ENDPOINT > /dev/null

echo "Creating local SNS topic..."
SNS_TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_NAME --endpoint-url=$ENDPOINT --output text --query 'TopicArn')

echo "Subscribing notification endpoint to SNS topic..."
aws sns subscribe \
    --topic-arn "$SNS_TOPIC_ARN" --endpoint-url "$ENDPOINT" \
    --protocol http --notification-endpoint "$SNS_NOTIFICATION_ENDPOINT" \
    --attributes '{"RawMessageDelivery":"false","FilterPolicyScope":"MessageBody","FilterPolicy":"{\"event_name\":[\"apply.submission\"]}"}' > /dev/null

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
echo "variables in your '.env.development.local' file. Do not declare the"
echo "SNS topic to disable the publishing of SNS events."
echo
echo "  EVENTS_SNS_TOPIC_ARN=$SNS_TOPIC_ARN"
echo "  S3_BUCKET_NAME=$BUCKET_NAME"
echo
echo "The SNS notification subscription will fail if Review is not running."
echo "Unless you are working on notifications, it is safe to ignore."
echo
