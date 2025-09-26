module Deleting
  class Deletable
    include AggregateRoot
    class AlreadySoftDeleted < StandardError; end
    class AlreadyHardDeleted < StandardError; end

    attr_reader :business_reference, :deletion_at

    on Applying::DraftCreated do |event|
      @application_type = event.data.fetch(:entity_type)
      @business_reference = event.data.fetch(:business_reference)
      @active_drafts += 1
      @deletion_at = timestamp(event) + 2.years
    end

    on Applying::DraftUpdated do |event|
      @deletion_at = timestamp(event) + 2.years
    end

    on Applying::DraftDeleted do |_event|
      @deletion_log_entry = nil
      @active_drafts -= 1
    end

    on Applying::Submitted do |event|
      @deletion_at = timestamp(event) + 2.years
    end

    on Deciding::MaatRecordCreated do |event|
      @injected_into_maat = true
      @maat_id = event.data.fetch(:maat_id)
    end

    # :nocov:
    on Deciding::Decided do |event|
      @decision = Decision.find_by(crime_application_id: event.data.fetch(:entity_id))
      @deletion_at = timestamp(event) + 2.years
    end
    # :nocov:

    on Reviewing::SentBack do |event|
      @application_returned = true
      @deletion_at = timestamp(event) + 2.years
    end

    # :nocov:
    on Reviewing::Completed do |event|
      @deletion_at = timestamp(event) + 2.years
    end
    # :nocov:

    on Deleting::SoftDeleted do |event|
      @soft_deleted_at = timestamp(event)
      @deletion_at = timestamp(event) + 2.weeks
    end

    on Deleting::HardDeleted do |event|
      @hard_deleted_at = timestamp(event)
      @deletion_log_entry = DeletionEntry.find_by(business_reference:)
    end

    # :nocov:
    on Deleting::ExemptFromDeletion do |event|
      @exempt_from_deletion = true
      @exemption_reason = event.data.fetch(:reason)
      @exempt_until = event.data.fetch(:exempt_until)
      @deletion_at = @exempt_until + 2.years
    end
    # :nocov:

    def initialize
      @active_drafts = 0
    end

    def soft_delete(entity_id:, reason:, deleted_by:)
      raise AlreadySoftDeleted if soft_deleted?

      apply Deleting::SoftDeleted.new(
        data: {
          entity_id: entity_id,
          entity_type: @application_type,
          business_reference: @business_reference,
          reason: reason,
          deleted_by: deleted_by
        }
      )
    end

    def hard_delete(entity_id:)
      raise AlreadyHardDeleted if hard_deleted?

      apply Deleting::HardDeleted.new(
        data: {
          entity_id: entity_id,
          entity_type: @application_type,
          business_reference: @business_reference,
        }
      )
    end

    def soft_deletable?
      return false unless @application_returned
      return false if active_drafts?

      @deletion_at <= Time.zone.now && !@injected_into_maat
    end

    def hard_deletable?
      return false if @soft_deleted_at.nil?

      @deletion_at <= Time.zone.now
    end

    private

    def active_drafts?
      @active_drafts.positive?
    end

    def soft_deleted?
      @soft_deleted_at.present?
    end

    def hard_deleted?
      @hard_deleted_at.present?
    end

    def timestamp(event)
      event.timestamp || Time.zone.now
    end
  end
end
