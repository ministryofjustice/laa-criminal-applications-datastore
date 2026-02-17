module Deleting
  module Handlers
    class UpdateApplicationSoftDeleted
      def call(event)
        crime_applications = CrimeApplication.where(reference: event.data.fetch(:business_reference))
        soft_deleted_at = event.metadata.fetch(:timestamp)
        crime_applications.update_all(soft_deleted_at:) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
