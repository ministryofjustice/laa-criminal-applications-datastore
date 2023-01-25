module Operations
  class ReturnApplication
    def initialize(application_id:, return_details:)
      @application = CrimeApplication.find(application_id)
      @return_details = @application.build_return_details(return_details)
    end

    def call
      raise Errors::AlreadyReturned if application.returned?

      application.transaction do
        return_details.save!

        application.update!(
          status: Types::ApplicationStatus['returned'],
          review_status: Types::ReviewApplicationStatus['returned_to_provider'],
          returned_at: return_details.created_at,
          reviewed_at: Time.zone.now
        )
      end

      application
    end

    private

    attr_reader :application, :return_details
  end
end
