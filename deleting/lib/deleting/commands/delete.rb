module Deleting
  module Commands
    class Delete
      def initialize(business_reference:, reason:, deleted_by:)
        @business_reference = business_reference
        @reason = Types::DeletionReason[reason]
        @deleted_by = deleted_by
      end

      def call
        repository.with_deletable(@business_reference) do |deletable|
          if deletable.hard_deletable?
            deletable.hard_delete(reason:, deleted_by:)
          elsif deletable.soft_deletable?
            deletable.soft_delete(reason:, deleted_by:)
          else
            # This may happen if there is a draft application in Apply pending hard-deletion
            Rails.logger.warn("Application #{business_reference} is not ready for deletion")
          end
        end
      end

      private

      attr_reader :business_reference, :reason, :deleted_by

      def repository
        @repository ||= Deleting::DeletableRepository.new
      end
    end
  end
end
