module Events
  class SoftDeleted < BaseEvent
    def name
      'datastore.soft_deleted'.freeze
    end

    def message
      {
        soft_deleted_at: crime_application.soft_deleted_at,
        reference: crime_application.reference,
        reason: Types::DeletionReason['retention_rule'],
        deleted_by: 'system_automated'
      }
    end
  end
end
