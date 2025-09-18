module Operations
  class DraftCreated
    attr_reader :entity_id, :entity_type, :business_reference

    def initialize(entity_id:, entity_type:, business_reference:)
      @entity_id = entity_id
      @entity_type = entity_type
      @business_reference = business_reference
    end

    def call
      event = Applying::DraftCreated.new(data: { business_reference:, entity_id:, entity_type: })
      Rails.configuration.event_store.publish(event)
    end
  end
end
