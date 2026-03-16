# Rake task to backfill Deleting::Archived events for archived applications
#
# Creates Deleting::Archived events for any applications that don't have a
# corresponding Deleting::Archived event in the event store.
# When the Deleting::Archived event is published, it automatically triggers the
# Applying::Handlers::PublishArchivedSns handler which publishes the Events::Archived SNS event.
# This will enable the same event to be created in Review and linked to the new Reference History stream.
#
# Usage:
#   bundle exec rake backfill_archived_events
#   DRY_RUN=true bundle exec rake backfill_archived_events
#
desc 'Backfill Deleting::Archived events for archived applications'
task backfill_archived_events: [:environment] do
  $stdout.sync = true
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = Logger::INFO
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)

  dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
  event_store = Rails.configuration.event_store

  logger.info "Starting backfill of Deleting::Archived events...#{ ' (DRY RUN)' if dry_run }"
  archived_count = 0

  # Get all existing Deleting::Archived events to avoid duplicates
  existing_archived_refs = event_store.read.of_type([Deleting::Archived]).to_a.map do |event|
    event.data[:business_reference]
  end.compact.to_set

  CrimeApplication.where.not(archived_at: nil).find_each do |application|
    if existing_archived_refs.include?(application.reference)
      logger.debug "Deleting::Archived event already exists for application #{application.id}"
      next
    end

    archived_count += 1

    if dry_run
      logger.info "Would create Deleting::Archived event for application #{application.id} (reference: #{application.reference})"
      next
    end

    logger.info "Creating Deleting::Archived event for application #{application.id}"

    event = Deleting::Archived.new(
      data: {
        business_reference: application.reference,
        entity_id: application.id,
        entity_type: application.application_type,
        archived_at: application.archived_at
      }
    )

    # Note: Publishing this event will trigger the Applying::Handlers::PublishArchivedSns handler
    # which will automatically publish the Events::Archived SNS event
    event_store.with_metadata(timestamp: application.archived_at) do
      event_store.publish(event)
    end
  end

  if dry_run
    logger.info "DRY RUN: Would backfill #{archived_count} Deleting::Archived events"
  else
    logger.info "Backfilled #{archived_count} Deleting::Archived events (SNS events published automatically via handler)"
  end
end

# Rake task to publish Events::SoftDeleted SNS events for soft deleted applications
#
# Publishes Events::SoftDeleted SNS events for any applications that have a
# Deleting::SoftDeleted event in the event store.
#
# Usage:
#   bundle exec rake publish_soft_deleted_sns_events
#   DRY_RUN=true bundle exec rake publish_soft_deleted_sns_events
#   LIMIT=100 bundle exec rake publish_soft_deleted_sns_events
#   START_AFTER_ID=<event-id> LIMIT=100 bundle exec rake publish_soft_deleted_sns_events
#
desc 'Publish Events::SoftDeleted SNS events for applications with Deleting::SoftDeleted events'
task publish_soft_deleted_sns_events: [:environment] do
  $stdout.sync = true
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = Logger::INFO
  Rails.logger = ActiveSupport::TaggedLogging.new(logger)

  dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
  limit = ENV["LIMIT"]&.to_i
  start_after_id = ENV["START_AFTER_ID"]
  event_store = Rails.configuration.event_store

  logger.info "Starting publication of Events::SoftDeleted SNS events...#{ ' (DRY RUN)' if dry_run }"
  logger.info "Limit: #{limit || 'none'}, Start after ID: #{start_after_id || 'none'}"
  published_count = 0

  reader = event_store.read.of_type([Deleting::SoftDeleted])
  reader = reader.from(start_after_id) if start_after_id
  reader = reader.limit(limit) if limit
  soft_deleted_events = reader.to_a

  logger.info "Found #{soft_deleted_events.count} Deleting::SoftDeleted events to process"

  soft_deleted_events.each do |event|
    business_reference = event.data.fetch(:business_reference)
    soft_deleted_at = event.metadata.fetch(:timestamp)

    published_count += 1

    if dry_run
      logger.info "Would publish Events::SoftDeleted SNS event for application #{business_reference} (event ID: #{event.event_id})"
      next
    end

    logger.info "Publishing Events::SoftDeleted SNS event for application #{business_reference} (event ID: #{event.event_id})"

    Events::SoftDeleted.new(
      reference: business_reference,
      soft_deleted_at: soft_deleted_at
    ).publish
  end

  if dry_run
    logger.info "DRY RUN: Would publish #{published_count} Events::SoftDeleted SNS events"
  else
    logger.info "Published #{published_count} Events::SoftDeleted SNS events"
    logger.info "Last processed event ID: #{soft_deleted_events.last&.event_id}" if soft_deleted_events.any?
  end
end