module Deleting
  module Handlers
    class ClearApplicationSoftDeleted
      def call(event)
        crime_application = CrimeApplication.find(event.data.fetch(:entity_id))
        crime_application.update!(soft_deleted_at: nil)
      end
    end
  end
end
