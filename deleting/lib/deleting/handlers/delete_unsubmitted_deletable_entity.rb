module Deleting
  module Handlers
    class DeleteUnsubmittedDeletableEntity
      def call(event)
        return unless event.instance_of?(Applying::DraftDeleted)

        business_reference = event.data.fetch(:business_reference)
        repository = Deleting::DeletableRepository.new
        repository.with_deletable(business_reference) do |deletable|
          deletable_entity = DeletableEntity.find_by(business_reference:)
          deletable_entity.destroy! if deletable_entity.present? && deletable.never_submitted?
        end
      end
    end
  end
end
