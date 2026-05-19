desc 'Monitor deletion log count and report metric to Prometheus'
task monitor_deletion_log: [:environment] do
  $stdout.sync = true
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = Logger::INFO
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)

  current_count = DeletionEntry.count
  previous_snapshot = DeletionLogSnapshot.order(recorded_at: :desc).first
  previous_count = previous_snapshot&.count

  # Save current count for next run
  DeletionLogSnapshot.create!(count: current_count, recorded_at: Time.current)

  # Report metric to Prometheus (alerts are triggered via PrometheusRule)
  PrometheusMetrics::DeletionLogReporter.report(current_count)

  change = previous_count ? current_count - previous_count : 0

  if previous_count.nil?
    Rails.logger.info("Deletion log monitor initialised. Current count: #{current_count}")
  elsif change.negative?
    Rails.logger.error("Deletion log has DECREASED! Previous: #{previous_count}, Current: #{current_count}, Change: #{change}")
  else
    Rails.logger.info("Deletion log daily report. Current count: #{current_count} (+#{change} since last check)")
  end
end
