module Operations
  class ReturnApplication
    def initialize(application_id:, return_details:)
      @application = CrimeApplication.find(application_id)
      @return_details = return_details
    end

    # rubocop:disable Metrics/MethodLength
    def call
      validate_application!

      application.transaction do
        now = Time.zone.now

        application.update!(
          status: Types::ApplicationStatus['returned'],
          review_status: Types::ReviewApplicationStatus['returned_to_provider'],
          reviewed_at: now,
          returned_at: now,
          return_details: return_details,
        )

        # Publish event notification to the SNS topic
        Events::Returned.new(application).publish

        publish_to_event_store
      end

      application
    end
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :application, :return_details

    def validate_application!
      raise Errors::AlreadyReturned if application.returned?
      raise Errors::AlreadyCompleted if application.assessment_completed?
    end

    def publish_to_event_store
      Rails.configuration.event_store.publish(
        Reviewing::SentBack.from_application(application)
      )
    end
  end
end
