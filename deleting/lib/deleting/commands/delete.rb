module Deleting
  module Commands
    class Delete
      def initialize(business_reference:, reason:, deleted_by:)
        @business_reference = business_reference
        @reason = reason
        @deleted_by = deleted_by
      end

      def call
        repository.with_deletable(@business_reference) do |deletable|
          if deletable.hard_deletable?
            hard_delete(deletable)
          elsif deletable.soft_deletable?
            soft_delete(deletable)
          else
            Rails.logger.warn("Application #{business_reference} is not ready for deletion")
          end
        end
      end

      private

      attr_reader :business_reference, :reason, :deleted_by

      def soft_delete(deletable)
        deletable.soft_delete(entity_id:, reason:, deleted_by:)
      end

      def hard_delete(deletable)
        # TODO: redact latest and superseded records
        # TODO: remove attachments
        deletion_entry = DeletionEntry.create!(
          record_id: entity_id,
          record_type: Types::RecordType['application'],
          business_reference: business_reference,
          deleted_by: deleted_by,
          reason: reason
        )
        deletable.hard_delete(entity_id: entity_id, deletion_entry_id: deletion_entry.id)
      end

      def entity_id
        @entity_id ||= CrimeApplication.latest(business_reference).first.id
      end

      def repository
        @repository ||= Deleting::DeletableRepository.new
      end
    end
  end
end
