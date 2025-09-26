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

  class Configuration
    class << self
      def call(event_store)
        event_store.subscribe(Deleting::Handlers::LinkToStream, to:
          [
            Applying::DraftCreated,
            Applying::DraftUpdated,
            Applying::DraftDeleted,
            Applying::Submitted,
            Deciding::MaatRecordCreated,
            Deciding::Decided,
            Reviewing::SentBack,
            Reviewing::Completed
          ])
        event_store.subscribe(Deleting::Handlers::UpdateReadModel, to: EVENTS)
      end
    end
  end
end
