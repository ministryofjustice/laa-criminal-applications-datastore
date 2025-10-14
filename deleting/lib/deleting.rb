module Deleting
  class Event < RailsEventStore::Event; end
  class SoftDeleted < Event; end
  class HardDeleted < Event; end
  class ExemptFromDeletion < Event; end
  class ApplicationMigrated < Event; end

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
    ExemptFromDeletion,
    ApplicationMigrated
  ].freeze

  class << self
    def stream_name(business_reference)
      "Deleting$#{business_reference}"
    end
  end

  class Configuration
    class << self
      def call(event_store) # rubocop:disable Metrics/MethodLength
        event_store.subscribe(Deleting::Handlers::LinkToStream, to:
          [
            Applying::DraftCreated,
            Applying::DraftUpdated,
            Applying::DraftDeleted,
            Applying::Submitted,
            Deciding::MaatRecordCreated,
            Deciding::Decided,
            Reviewing::SentBack,
            Reviewing::Completed,
            Deleting::ApplicationMigrated
          ])
        event_store.subscribe(Deleting::Handlers::UpdateReadModel, to: EVENTS)
        event_store.subscribe(Deleting::Handlers::UpdateApplicationSoftDeleted, to: [Deleting::SoftDeleted])
      end
    end
  end
end
