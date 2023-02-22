module Operations
  class ReturnApplication
    def initialize(application_id:, return_details:)
      @application = CrimeApplication.find(application_id)
      @return_details = @application.build_return_details(return_details)
    end

    def call
      validate_application!

      application.transaction do
        return_details.save!

        application.update!(
          status: Types::ApplicationStatus['returned'],
          review_status: Types::ReviewApplicationStatus['returned_to_provider'],
          returned_at: return_details.created_at,
          reviewed_at: Time.zone.now
        )

        # Publish event notification to the SNS topic
        Events::Returned.new(application).publish
      end

      application
    end

    private

    attr_reader :application, :return_details

    def validate_application!
      raise Errors::AlreadyReturned if application.returned?
      raise Errors::AlreadyCompleted if application.assessment_completed?
    end
  end
end
