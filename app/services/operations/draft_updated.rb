module Operations
  class DraftUpdated
    attr_reader :entity_id, :entity_type, :business_reference

    def initialize(entity_id:, entity_type:, business_reference:)
      @entity_id = entity_id
      @entity_type = entity_type
      @business_reference = business_reference
    end

    def call
      event = Applying::DraftUpdated.new(data: { business_reference:, entity_id:, entity_type: })
      Rails.configuration.event_store.publish(event)
      event
    end
  end
end
