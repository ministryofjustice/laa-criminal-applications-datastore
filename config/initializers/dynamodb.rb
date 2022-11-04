require 'dynamoid'

Dynamoid.configure do |config|
  # To namespace tables created by Dynamoid from other tables you might have.
  # Set to nil to avoid namespacing.
  config.namespace = ENV.fetch('DYNAMO_TABLE_NAMESPACE', nil)

  # [Optional]. If provided, it communicates with the DB listening at the endpoint.
  # This is useful for testing with DynamoDB Local
  # (http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html).
  config.endpoint = ENV.fetch('DYNAMO_ENDPOINT')

  # AWS region, sensible default but can use ENV variable too
  config.region = ENV.fetch('AWS_REGION', 'eu-west-2')
end
