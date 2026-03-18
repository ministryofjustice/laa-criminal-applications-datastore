module Events
  class Archived
    attr_reader :event_data

    def initialize(event_data)
      @event_data = event_data
    end

    def name
      'Deleting::Archived'.freeze
    end

    def message
      {
        id: event_data.fetch(:entity_id),
        archived_at: event_data.fetch(:archived_at),
        application_type: event_data.fetch(:entity_type),
        reference: event_data.fetch(:business_reference)
      }
    end

    def publish
      Messaging::EventsPublisher.publish(self)
    end
  end
end
