module Operations
  class CompleteApplication
    def initialize(application_id:, decisions:)
      @application = CrimeApplication.find(application_id)
      @decisions = decisions
    end

    def call
      raise Errors::AlreadyCompleted if application.assessment_completed?
      raise Errors::AlreadyReturned if application.returned?

      application.transaction do
        application.update!(
          review_status: Types::ReviewApplicationStatus['assessment_completed'],
          reviewed_at: Time.zone.now,
          decisions: decisions.map{|d| Decision.new(d)}
        )
      end

      application
    end

    private

    attr_reader :application, :decisions
  end
end
