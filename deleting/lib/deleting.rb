module Deleting
  class Event < RailsEventStore::Event; end
  class SoftDeleted < Event; end
  class HardDeleted < Event; end
  class ExemptFromDeletion < Event; end

  EVENTS = [
    Applying::DraftCreated,
    Applying::DraftUpdated,
    Applying::DraftDeleted,
    Applying::Submitted,
    Deciding::MaatRecordCreated,
    Deciding::Decided,
    Reviewing::SentBack,
    Reviewing::Completed,
    SoftDeleted,
    HardDeleted,
    ExemptFromDeletion
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

  SUBSCRIBERS = [
    LinkToStream,
  ].freeze

  class Configuration
    class << self
      def call(event_store)
        SUBSCRIBERS.each { |subscriber| event_store.subscribe(subscriber, to: EVENTS) }
      end
    end
  end
end
