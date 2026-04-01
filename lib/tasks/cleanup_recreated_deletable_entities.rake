# Rake task to remove recreated DeletableEntity records for applications
# that have already been hard deleted.
#
# The backfill_archived_events rake task published Deleting::Archived events
# for archived applications, including those that had already been hard deleted.
# This triggered the UpdateReadModel handler which recreated DeletableEntity
# rows for those hard-deleted applications.
#
# Usage:
#   DRY_RUN=true bundle exec rake cleanup_recreated_deletable_entities
#   bundle exec rake cleanup_recreated_deletable_entities
#
desc 'Remove recreated DeletableEntity records for applications that have already been hard deleted'
task cleanup_recreated_deletable_entities: [:environment] do
  $stdout.sync = true
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = Logger::INFO
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)

  dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch('DRY_RUN', nil))

  logger.info "Starting cleanup of recreated DeletableEntity records...#{' (DRY RUN)' if dry_run}"

  removed_count = cleanup_entities(dry_run, logger)

  if dry_run
    logger.info "DRY RUN: Would remove #{removed_count} recreated DeletableEntity records"
  else
    logger.info "Removed #{removed_count} recreated DeletableEntity records"
  end
end

def cleanup_entities(dry_run, logger) # rubocop:disable Metrics/MethodLength
  repository = Deleting::DeletableRepository.new
  count = 0

  DeletableEntity.expired.find_each do |deletable_entity|
    repository.with_deletable(deletable_entity.business_reference) do |deletable|
      next unless deletable.hard_deleted?

      count += 1

      if dry_run
        logger.info "Would remove recreated DeletableEntity for reference #{deletable_entity.business_reference}"
      else
        logger.info "Removing recreated DeletableEntity for reference #{deletable_entity.business_reference}"
        deletable_entity.destroy!
      end
    end
  end

  count
end
