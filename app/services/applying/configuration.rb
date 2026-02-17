module Applying
  class Configuration
    class << self
      def call(event_store)
        event_store.subscribe(Applying::Handlers::PublishArchivedSns, to: [Applying::Archived])
      end
    end
  end
end
