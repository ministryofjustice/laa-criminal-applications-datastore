module Deleting
  module Handlers
    class UpdateApplicationSoftDeleted
      def call(event)
        crime_application = CrimeApplication.find(event.data.fetch(:entity_id))
        soft_deleted_at = event.metadata.fetch(:timestamp)
        crime_application.update!(soft_deleted_at:)
      end
    end
  end
end
