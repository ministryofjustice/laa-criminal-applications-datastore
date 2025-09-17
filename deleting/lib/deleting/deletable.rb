module Deleting
  class Deletable
    include AggregateRoot

    attr_reader :business_reference, :deletion_at

    on Applying::DraftCreated do |event|
      @application_type = event.data.fetch(:entity_type)
      @business_reference = event.data.fetch(:business_reference)
      @active_drafts += 1
      @deletion_at = event.timestamp + 2.years
    end

    on Applying::DraftUpdated do |event|
      @deletion_at = event.timestamp + 2.years
    end

    on Applying::DraftDeleted do |_event|
      @deletion_log_entry = nil
      @active_drafts -= 1
    end

    on Applying::Submitted do |event|
      @deletion_at = event.timestamp + 2.years
    end

    on Deciding::MaatRecordCreated do |event|
      @injected_into_maat = true
      @maat_id = event.data.fetch(:maat_id)
    end

    # :nocov:
    on Deciding::Decided do |event|
      @decision = Decision.find_by(crime_application_id: event.data.fetch(:entity_id))
      @deletion_at = event.timestamp + 2.years
    end

    on Reviewing::SentBack do |event|
      @application_returned = true
      @deletion_at = event.timestamp + 2.years
    end

    on Reviewing::Completed do |event|
      @deletion_at = event.timestamp + 2.years
    end

    on Deleting::SoftDeleted do |event|
      @soft_deleted_at = event.timestamp
      @deletion_at = event.timestamp + 2.weeks
    end

    on Deleting::HardDeleted do |event|
      @hard_deleted_at = event.timestamp
      @deletion_log_entry = nil
    end

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

    def soft_deletable?
      return false unless @application_returned
      return false if active_drafts?

      @deletion_at <= Time.zone.now && !@injected_into_maat
    end

    private

    def active_drafts?
      @active_drafts.positive?
    end
  end
end
