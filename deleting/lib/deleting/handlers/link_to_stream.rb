module Deleting
  module Handlers
    class LinkToStream
      def initialize(event_store: Rails.configuration.event_store)
        @event_store = event_store
      end

      def call(event)
        stream_name = Deleting.stream_name(event.data.fetch(:business_reference))
        @event_store.link(event.event_id, stream_name:)
      end
    end
  end
end
