module Events
  class SoftDeleted
    attr_reader :reference, :soft_deleted_at

    def initialize(reference:, soft_deleted_at:)
      @reference = reference
      @soft_deleted_at = soft_deleted_at
    end

    def name
      'Deleting::SoftDeleted'.freeze
    end

    def message
      {
        soft_deleted_at: soft_deleted_at,
        reference: reference,
        reason: Types::DeletionReason['retention_rule'],
        deleted_by: 'system_automated'
      }
    end

    # Convenience method as currently we only have
    # one SNS topic and one publisher
    def publish
      Messaging::EventsPublisher.publish(self)
    end
  end
end
