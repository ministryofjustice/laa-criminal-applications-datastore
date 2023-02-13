module Operations
  class CompleteApplication
    def initialize(application_id:)
      @application = CrimeApplication.find(application_id)
    end

    def call
      raise Errors::AlreadyCompleted if application.assessment_completed?
      raise Errors::AlreadyReturned if application.returned?

      application.transaction do
        application.update!(
          review_status: Types::ReviewApplicationStatus['assessment_completed'],
          reviewed_at: Time.zone.now
        )
      end

      application
    end

    private

    attr_reader :application
  end
end
