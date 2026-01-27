module Operations
  class DraftDeleted
    attr_reader :entity_id, :entity_type, :business_reference, :reason, :deleted_by, :deleted_from

    def initialize(entity_id:, entity_type:, business_reference:, reason:, deleted_by:)
      @entity_id = entity_id
      @entity_type = entity_type
      @business_reference = business_reference
      @reason = reason
      @deleted_by = deleted_by
      @deleted_from = Types::RecordSource['crime_apply']
    end

    def call
      event = Applying::DraftDeleted.new(
        data: {
          business_reference:,
          entity_id:,
          entity_type:,
          reason:,
          deleted_by:,
          deleted_from:
        }
      )
      Rails.configuration.event_store.publish(event)
      Datastore::Entities::V1::EventResponse.represent(event)
    end
  end
end
