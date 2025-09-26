module Deleting
  module Handlers
    class UpdateReadModel
      def call(event)
        business_reference = event.data.fetch(:business_reference)

        return DeletableEntity.find_by(business_reference:).destroy! if event.instance_of?(Deleting::HardDeleted)

        repository = Deleting::DeletableRepository.new
        repository.with_deletable(business_reference) do |deletable|
          DeletableEntity.upsert( # rubocop:disable Rails/SkipsModelValidations
            { business_reference: deletable.business_reference, review_deletion_at: deletable.deletion_at },
            unique_by: :business_reference
          )
        end
      end
    end
  end
end
