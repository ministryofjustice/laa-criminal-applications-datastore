module Deleting
  SOFT_DELETION_PERIOD = Rails.configuration.x.automated_deletion_test_mode == 'true' ? 10.minutes : 30.days

  class Event < RubyEventStore::Event; end
  class SoftDeleted < Event; end
  class HardDeleted < Event; end
  class ExemptFromDeletion < Event; end
  class ApplicationMigrated < Event; end
  class Archived < Event; end

  class UnexpectedEventType < StandardError; end

  EVENTS = [
    Applying::DraftCreated,
    Applying::DraftDeleted,
    Applying::Submitted,
    Deciding::MaatRecordCreated,
    Deciding::MaatRecordUpdated,
    Deciding::Decided,
    Deciding::DecisionUpdated,
    Reviewing::SentBack,
    Reviewing::Completed,
    SoftDeleted,
    HardDeleted,
    ExemptFromDeletion,
    ApplicationMigrated,
    Archived
  ].freeze

  class << self
    def stream_name(business_reference)
      "Deleting$#{business_reference}"
    end
  end

  class Configuration
    class << self
      def call(event_store) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        event_store.subscribe(Deleting::Handlers::LinkToStream.new, to:
          [
            Applying::DraftCreated,
            Applying::DraftDeleted,
            Applying::Submitted,
            Deciding::MaatRecordCreated,
            Deciding::Decided,
            Reviewing::SentBack,
            Reviewing::Completed,
            Deleting::ApplicationMigrated,
            Deleting::Archived
          ])
        event_store.subscribe(Deleting::Handlers::UpdateReadModel.new, to: EVENTS)
        event_store.subscribe(Deleting::Handlers::UpdateApplicationSoftDeleted.new, to: [Deleting::SoftDeleted])
        event_store.subscribe(Deleting::Handlers::PublishSoftDeletedSns.new, to: [Deleting::SoftDeleted])
        event_store.subscribe(Deleting::Handlers::PublishArchivedSns.new, to: [Deleting::Archived])
        event_store.subscribe(Deleting::Handlers::ClearApplicationSoftDeleted.new, to: [Deleting::ExemptFromDeletion])
        event_store.subscribe(Deleting::Handlers::DeleteUnsubmittedDeletableEntity.new, to: [Applying::DraftDeleted])
        event_store.subscribe(Deleting::Handlers::HardDeleteDocuments.new, to: [Deleting::HardDeleted])
        event_store.subscribe(Deleting::Handlers::HardDeleteSubmittedApplications.new, to: [Deleting::HardDeleted])
      end
    end
  end
end
