module Deleting
  module Handlers
    class UpdateApplicationSoftDeleted
      def call(event)
        crime_applications = CrimeApplication.where(reference: event.data.fetch(:business_reference))
        soft_deleted_at = event.metadata.fetch(:timestamp)
        crime_applications.update_all(soft_deleted_at:) # rubocop:disable Rails/SkipsModelValidations

        # Publish event notification to the SNS topic
        # We only want to publish one event per business reference so we take the first application
        # from the collection to publish the event with.
        Events::SoftDeletion.new(crime_applications.order(:submitted_at).first).publish
      end
    end
  end
end
