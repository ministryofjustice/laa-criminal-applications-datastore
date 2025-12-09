module Deleting
  SOFT_DELETION_PERIOD = 30.days

  class Event < RailsEventStore::Event; end
  class SoftDeleted < Event; end
  class HardDeleted < Event; end
  class ExemptFromDeletion < Event; end
  class ApplicationMigrated < Event; end

  class UnexpectedEventType < StandardError; end

  EVENTS = [
    Applying::DraftCreated,
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
        event_store.subscribe(Deleting::Handlers::ClearApplicationSoftDeleted, to: [Deleting::ExemptFromDeletion])
        event_store.subscribe(Deleting::Handlers::DeleteUnsubmittedDeletableEntity, to: [Applying::DraftDeleted])
        event_store.subscribe(Deleting::Handlers::HardDeleteDocuments, to: [Deleting::HardDeleted])
        event_store.subscribe(Deleting::Handlers::HardDeleteSubmittedApplications, to: [Deleting::HardDeleted])
      end
    end
  end
end
