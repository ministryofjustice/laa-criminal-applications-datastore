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
        # TODO: update crime_application.soft_deleted_at ? is that necessary?
        # could we just rely on the aggregate to tell us if/when an app was soft_deleted and expose in API responses?
        # if we're updating soft_deleted_at, should we update it on all past/superseded apps?
        deletable.soft_delete(entity_id:, reason:, deleted_by:)
      end

      def hard_delete(deletable)
        # TODO: redact latest and superseded records
        # TODO: remove attachments
        DeletionEntry.create!(
          record_id: entity_id,
          record_type: Types::RecordType['application'],
          business_reference: business_reference,
          deleted_by: deleted_by,
          reason: reason
        )
        deletable.hard_delete(entity_id:)
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
