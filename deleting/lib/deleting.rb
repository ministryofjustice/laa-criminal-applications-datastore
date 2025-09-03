module Deleting
  EVENTS = [
    Applying::DraftCreated,
    Applying::DraftUpdated,
    Applying::DraftDeleted,
    Applying::Submitted,
    Deciding::MaatRecordCreated,
    Reviewing::SentBack,
    Reviewing::Completed
  ].freeze

  class << self
    def stream_name(business_reference)
      "Deleting$#{business_reference}"
    end
  end

  class LinkToStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      stream_name = Deleting.stream_name(event.data.fetch(:business_reference))
      @event_store.link(event.event_id, stream_name:)
    end
  end

  class Configuration
    class << self
      def call(event_store)
        event_store.subscribe(LinkToStream, to: EVENTS)
      end
    end
  end
end
