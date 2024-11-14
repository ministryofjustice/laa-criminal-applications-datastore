module Operations
  class CompleteApplication
    def initialize(application_id:, decisions:)
      @application = CrimeApplication.find(application_id)
      @decisions = decisions
      # TODO: revert after user research
      # validate!
    end

    def call # rubocop:disable Metrics/AbcSize
      raise Errors::AlreadyCompleted if application.assessment_completed?
      raise Errors::AlreadyReturned if application.returned?

      application.transaction do
        application.update!(
          review_status: Types::ReviewApplicationStatus['assessment_completed'],
          reviewed_at: Time.zone.now,
          decisions: decisions.map { |d| Decision.new(d) }
        )
      end

      application
    end

    private

    def validate!
      schema_validator = LaaCrimeSchemas::Validator.new(@decisions, version: 1.0, schema_name: 'general/decision',
list: true)
      return if schema_validator.valid?

      raise LaaCrimeSchemas::Errors::ValidationError, schema_validator.fully_validate
    end

    attr_reader :application, :decisions
  end
end
