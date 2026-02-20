module Deleting
  module Handlers
    class PublishSoftDeletedSns
      def call(event)
        business_reference = event.data.fetch(:business_reference)
        soft_deleted_at = event.metadata.fetch(:timestamp)

        Events::SoftDeleted.new(reference: business_reference, soft_deleted_at: soft_deleted_at).publish
      end
    end
  end
end
