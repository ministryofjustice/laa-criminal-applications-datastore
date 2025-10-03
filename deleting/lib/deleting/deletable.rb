module Deleting
  class Deletable # rubocop:disable Metrics/ClassLength
    include AggregateRoot
    class AlreadySoftDeleted < StandardError; end
    class AlreadyHardDeleted < StandardError; end

    attr_reader :business_reference, :deletion_at, :state

    STATES = [:submitted, :decided, :completed, :returned, :soft_deleted, :hard_deleted, :exempt_from_deletion].freeze

    STATES.each do |s|
      define_method(:"#{s}?") do
        state == s
      end
    end

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
      @state = :submitted
      @deletion_at = timestamp(event) + 2.years
    end

    on Deciding::MaatRecordCreated do |event|
      @injected_into_maat = true
      @maat_id = event.data.fetch(:maat_id)
    end

    # :nocov:
    on Deciding::Decided do |event|
      @decision_id = event.data.fetch(:decision_id)
      @overall_decision = event.data.fetch(:overall_decision)
      @state = :decided
      @deletion_at = timestamp(event) + 2.years
    end
    # :nocov:

    on Reviewing::SentBack do |event|
      @state = :returned
      @deletion_at = timestamp(event) + 2.years
    end

    # :nocov:
    on Reviewing::Completed do |event|
      @state = :completed
      @deletion_at = timestamp(event) + 2.years
    end
    # :nocov:

    on Deleting::SoftDeleted do |event|
      @state = :soft_deleted
      @soft_deleted_at = timestamp(event)
      @deletion_at = timestamp(event) + 2.weeks
    end

    on Deleting::HardDeleted do |event|
      @state = :hard_deleted
      @hard_deleted_at = timestamp(event)
      @deletion_entry_id = event.data.fetch(:deletion_entry_id)
    end

    # :nocov:
    on Deleting::ExemptFromDeletion do |event|
      @state = :exempt_from_deletion
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

    def hard_delete(entity_id:, deletion_entry_id:)
      raise AlreadyHardDeleted if hard_deleted?

      apply Deleting::HardDeleted.new(
        data: {
          entity_id: entity_id,
          entity_type: @application_type,
          business_reference: @business_reference,
          deletion_entry_id: deletion_entry_id
        }
      )
    end

    def soft_deletable?
      return false unless returned?
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

    def timestamp(event)
      event.timestamp || Time.zone.now
    end
  end
end
