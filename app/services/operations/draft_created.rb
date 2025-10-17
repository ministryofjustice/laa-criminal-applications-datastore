module Operations
  class DraftCreated
    attr_reader :entity_id, :entity_type, :business_reference, :created_at

    def initialize(entity_id:, entity_type:, business_reference:, created_at:)
      @entity_id = entity_id
      @entity_type = entity_type
      @business_reference = business_reference
      @created_at = created_at
    end

    def call
      event = Applying::DraftCreated.new(data: { business_reference:, entity_id:, entity_type:, created_at: })
      Rails.configuration.event_store.publish(event)
      Datastore::Entities::V1::EventResponse.represent(event)
    end
  end
end
