module Deleting
  module Handlers
    class HardDeleteSubmittedApplications
      def call(event)
        raise UnexpectedEventType unless event.is_a? HardDeleted

        business_reference = event.data.fetch(:business_reference)

        CrimeApplication.where(reference: business_reference).find_each do |application|
          application.destroy && create_deletion_entry(record_id: application.id, event: event)
        end
      end

      private

      def create_deletion_entry(record_id:, event:)
        DeletionEntry.create!(
          record_id: record_id,
          record_type: Types::RecordType['application'],
          business_reference: event.data.fetch(:business_reference),
          deleted_by: event.data.fetch(:deleted_by),
          deleted_from: Types::RecordSource['criminal_applications_datastore'],
          reason: event.data.fetch(:reason),
          correlation_id: event.correlation_id
        )
      end
    end
  end
end
