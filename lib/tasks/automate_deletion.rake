desc 'Automatically perform soft and hard deletion of applications that have reached the end of their retention period'
task automate_deletion: [:environment] do
  $stdout.sync = true
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = Logger::INFO
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)
  
  Deleting::AutomateDeletion.call
end
