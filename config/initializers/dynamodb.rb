require 'dynamoid'

Dynamoid.configure do |config|
  # To namespace tables created by Dynamoid from other tables you might have.
  # Set to nil to avoid namespacing.
  config.namespace = ENV.fetch('DYNAMO_TABLE_NAMESPACE', nil)

  # [Optional]. If provided, it communicates with the DB listening at the endpoint.
  # This is useful for testing with DynamoDB Local
  # (http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html).
  config.endpoint = ENV.fetch('DYNAMO_ENDPOINT', nil)

  # Miscellanea config
  config.timestamps = false
  config.store_date_as_string = true
  config.store_datetime_as_string = true
end
