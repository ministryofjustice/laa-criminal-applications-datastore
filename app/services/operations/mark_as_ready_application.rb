module Operations
  class MarkAsReadyApplication
    def initialize(application_id:)
      @application = CrimeApplication.find(application_id)
    end

    def call
      raise Errors::AlreadyMarkedAsReady if application.ready_for_assessment?
      raise Errors::AlreadyCompleted if application.assessment_completed?
      raise Errors::AlreadyReturned if application.returned?

      application.update!(
        review_status: Types::ReviewApplicationStatus['ready_for_assessment']
      )

      application
    end

    private

    attr_reader :application
  end
end
