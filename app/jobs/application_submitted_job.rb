class ApplicationSubmittedJob < ApplicationJob
  queue_as :datastore_submissions

  def perform(crime_application)
    Messages::ApplicationSubmitted.new(crime_application).process
  end
end
