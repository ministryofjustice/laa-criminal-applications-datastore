module Operations
  class CompleteApplication
    def initialize(application_id:, decisions:)
      @application = CrimeApplication.find(application_id)
      @decisions = decisions

      validate!
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
        publish_to_event_store
      end

      application
    end

    private

    def validate!
      errors = JSON::Validator.validate(
        schema, decisions, validate_schema: true,
        fragment: '#/properties/decisions',
        record_errors: true,
        errors_as_objects: true
      )

      return true if errors.empty?

      raise LaaCrimeSchemas::Errors::ValidationError, errors
    end

    def schema_version
      application.submitted_application['schema_version'].to_s
    end

    def schema
      File.join(LaaCrimeSchemas.root, 'schemas', schema_version, 'application.json')
    end

    def publish_to_event_store # rubocop:disable Metrics/AbcSize
      application.decisions.each do |decision|
        if decision.maat_id.present?
          Rails.configuration.event_store.publish(Deciding::MaatRecordCreated.from_application(
                                                    crime_application: application, maat_id: decision.maat_id
                                                  ))
        end
        Rails.configuration.event_store.publish(Deciding::Decided.from_application(crime_application: application,
                                                                                   decision: decision))
      end
      Rails.configuration.event_store.publish(
        Reviewing::Completed.from_application(application)
      )
    end

    attr_reader :application, :decisions
  end
end
