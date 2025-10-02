module Operations
  class MAATRecordCreated
    attr_reader :entity_id, :entity_type, :business_reference, :maat_id

    def initialize(entity_id:, entity_type:, business_reference:, maat_id:)
      @entity_id = entity_id
      @entity_type = entity_type
      @business_reference = business_reference
      @maat_id = maat_id
    end

    def call
      event = Deciding::MaatRecordCreated.new(data: { entity_id:, entity_type:, business_reference:, maat_id: })
      Rails.configuration.event_store.publish(event)
    end
  end
end
