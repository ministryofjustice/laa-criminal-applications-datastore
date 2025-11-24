module Deleting
  module Handlers
    class CreateDeletionEntry
      def call(event)
        DeletionEntry.create!(
          record_id: event.data.fetch(:entity_id),
          record_type: event.data.fetch(:entity_type),
          business_reference: event.data.fetch(:business_reference),
          deleted_by: event.data.fetch(:business_reference),
          deleted_from: event.data.fetch(:deleted_from),
          reason: event.data.fetch(:reason),
          correlation_id: event.correlation_id
        )
      end
    end
  end
end
