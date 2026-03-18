module Deleting
  module Handlers
    class PublishArchivedSns
      def call(event)
        Events::Archived.new(event.data).publish
      end
    end
  end
end
