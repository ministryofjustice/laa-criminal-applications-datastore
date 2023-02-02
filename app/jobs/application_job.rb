class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveRecord::RecordNotFound

  # :nocov:
  rescue_from ActiveJob::DeserializationError do |e|
    Rails.logger.error(e)
  end
  # :nocov:
end
