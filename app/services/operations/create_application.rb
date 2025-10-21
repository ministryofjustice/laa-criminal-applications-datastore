require 'laa_crime_schemas'

module Operations
  class CreateApplication
    attr_reader :payload

    def initialize(payload:)
      @payload = payload

      validate!
    end

    def call
      CrimeApplication.transaction do
        @app = CrimeApplication.create!(submitted_application: payload)
        SupersedeApplication.new(application_id: parent_id).call if parent_id

        # Publish event notification to the SNS topic
        Events::Submission.new(@app).publish

        publish_to_event_store
      end

      { id: @app.id }
    rescue ActiveRecord::RecordNotUnique
      raise Errors::AlreadySubmitted
    end

    private

    def validate!
      schema_validator = LaaCrimeSchemas::Validator.new(payload)
      return if schema_validator.valid?

      raise LaaCrimeSchemas::Errors::ValidationError, schema_validator.fully_validate
    end

    def parent_id
      payload.fetch('parent_id', nil)
    end

    def publish_to_event_store
      Rails.configuration.event_store.publish(
        Applying::Submitted.from_application(@app)
      )
    end
  end
end
