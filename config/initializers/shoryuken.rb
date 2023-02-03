Shoryuken.configure_server do |config|
  # Replace Rails logger so messages are logged wherever Shoryuken is logging
  # Note: this entire block is only run by the processor, so we don't overwrite
  #       the logger when the app is running as usual.
  Rails.logger = Shoryuken::Logging.logger
  Rails.logger.level = Rails.application.config.log_level

  config.active_job_queue_name_prefixing = true

  # Reduce number of requests against SQS (therefore reducing quota usage)
  config.cache_visibility_timeout = true
end

# For both, client and server, when running the queues locally
if ENV['LOCAL_ELASTICMQ_URL'].present?
  Shoryuken.sqs_client = Aws::SQS::Client.new(
    endpoint: ENV['LOCAL_ELASTICMQ_URL'],
    region: 'eu-west-2' # required, but irrelevant locally
  )
end
