module Deleting
  module Handlers
    class PublishArchivedSns
      def call(event)
        application_id = event.data.fetch(:entity_id)
        application = CrimeApplication.find(application_id)

        Events::Archived.new(application).publish
      end
    end
  end
end
