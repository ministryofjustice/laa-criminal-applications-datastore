desc 'Monitor deletion log count and report metric to Prometheus'
task monitor_deletion_log: [:environment] do
  $stdout.sync = true
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = Logger::INFO
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)

  current_count = DeletionEntry.count

  # Report metric to Prometheus (alerts are triggered via PrometheusRule)
  PrometheusMetrics::DeletionLogReporter.report(current_count)

  Rails.logger.info("Deletion log count reported to Prometheus: #{current_count}")
end
