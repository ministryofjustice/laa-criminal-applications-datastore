desc 'Migrate applications to Deleting event streams'
task migrate_applications: [:environment] do
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    $stdout.sync = true
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = Logger::Formatter.new
    logger.level = Logger::INFO

    Rails.logger = ActiveSupport::TaggedLogging.new(logger)
  end
  
  Deleting::MigrateApplications.new.call
end
