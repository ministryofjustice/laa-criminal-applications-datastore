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
          returned_at: return_details.created_at
        )
      end
    end

    private

    attr_reader :application, :return_details
  end
end
