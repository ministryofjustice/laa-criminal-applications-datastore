module Operations
  class DraftDeleted
    attr_reader :entity_id, :entity_type, :business_reference, :reason, :deleted_by

    def initialize(entity_id:, entity_type:, business_reference:, reason:, deleted_by:)
      @entity_id = entity_id
      @entity_type = entity_type
      @business_reference = business_reference
      @reason = reason
      @deleted_by = deleted_by
    end

    def call
      event = Applying::DraftDeleted.new(data: { business_reference:, entity_id:, entity_type:, reason:, deleted_by: })
      Rails.configuration.event_store.publish(event)
    end
  end
end
