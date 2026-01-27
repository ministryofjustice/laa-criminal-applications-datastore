module Deleting
  module Handlers
    class HardDeleteDocuments
      # Delete all documents for a given business_reference,
      # creating a deletion entry for each one.
      def call(event)
        raise UnexpectedEventType unless event.is_a? HardDeleted

        usn = event.data.fetch(:business_reference)

        Operations::Documents::List.new(usn:).call.each do |object|
          Operations::Documents::Delete.new(**object).call
          create_deletion_entry record_id: object.fetch(:object_key), event: event
        end
      end

      private

      def create_deletion_entry(record_id:, event:)
        DeletionEntry.create!(
          record_id: record_id,
          record_type: Types::RecordType['document'],
          business_reference: event.data.fetch(:business_reference),
          deleted_by: event.data.fetch(:deleted_by),
          deleted_from: Types::RecordSource['amazon_s3'],
          reason: event.data.fetch(:reason),
          correlation_id: event.correlation_id
        )
      end
    end
  end
end
