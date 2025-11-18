desc 'Delete ghost DeletableEntity records from the database'
task delete_ghost_deletable_entities: [:environment] do
  deleted_entities = []
  repository = Deleting::DeletableRepository.new
  DeletableEntity.expired.each do |deletable_entity|
    next if CrimeApplication.where(reference: deletable_entity.business_reference.to_i).any?

    repository.with_deletable(deletable_entity.business_reference) do |deletable|
      if deletable.never_submitted? && !deletable.active_drafts?
        deletable_entity.destroy!
        deleted_entities << deletable_entity.business_reference
      end
    end
  end

  puts 'Deleted DeletableEntity records:'
  pp deleted_entities
end
