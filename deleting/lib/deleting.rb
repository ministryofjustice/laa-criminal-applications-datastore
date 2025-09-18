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

  class UpdateReadModel
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      stream_name = Deleting.stream_name(event.data.fetch(:business_reference))
      deletable = AggregateRoot::Repository.new(@event_store).load(Deleting::Deletable.new, stream_name)
      DeletableEntity.upsert( # rubocop:disable Rails/SkipsModelValidations
        { business_reference: deletable.business_reference, review_deletion_at: deletable.deletion_at },
        unique_by: :business_reference
      )
    end
  end

  SUBSCRIBERS = [
    LinkToStream,
    UpdateReadModel
  ].freeze

  class Configuration
    class << self
      def call(event_store)
        SUBSCRIBERS.each { |subscriber| event_store.subscribe(subscriber, to: EVENTS) }
      end
    end
  end
end
