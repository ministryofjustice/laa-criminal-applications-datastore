module Deleting
  class MigrateApplications
    def call
      Rails.logger.info('Start of migration')

      crime_applications.find_each do |crime_application|
        migrate(crime_application)
        Rails.logger.info("Application #{crime_application.reference} migrated")
      end

      Rails.logger.info('End of migration')
    end

    private

    def migrate(crime_application) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      decision = crime_application.decisions&.first
      event = ApplicationMigrated.new(data:
      {
        business_reference: crime_application.reference,
        entity_id: crime_application.id,
        entity_type: crime_application.application_type,
        maat_id: crime_application.maat_id || decision&.maat_id,
        decision_id: decision&.id,
        overall_decision: decision&.overall_result,
        submitted_at: crime_application.submitted_at,
        returned_at: crime_application.returned_at,
        reviewed_at: crime_application.reviewed_at,
        last_updated_at: crime_application.reviewed_at || crime_application.submitted_at,
        review_status: crime_application.review_status
      })
      Rails.configuration.event_store.publish(event)
    end

    def crime_applications
      latest_per_reference =
        CrimeApplication
        .select(:reference)
        .select('MAX(submitted_at) AS submitted_at')
        .group(:reference)

      CrimeApplication
        .joins("INNER JOIN (#{latest_per_reference.to_sql}) latest
                ON latest.reference = crime_applications.reference
                AND latest.submitted_at = crime_applications.submitted_at")
    end
  end
end
