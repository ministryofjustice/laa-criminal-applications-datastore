module Deleting
  class Deletable # rubocop:disable Metrics/ClassLength
    include AggregateRoot

    class AlreadySoftDeleted < StandardError; end
    class AlreadyHardDeleted < StandardError; end
    class CannotBeExempt < StandardError; end
    class CannotHardDelete < StandardError; end
    class CannotSoftDelete < StandardError; end

    attr_reader :business_reference, :deletion_at, :state, :soft_deleted_at, :archived_at, :last_significant_event_at,
                :decision_ids, :maat_ids

    STATES = [:submitted, :decided, :completed, :returned, :soft_deleted, :hard_deleted, :exempt_from_deletion].freeze
    REVIEW_STATUS_TO_STATE = {
      'application_received' => :submitted,
      'ready_for_assessment' => :submitted,
      'returned_to_provider' => :returned,
      'assessment_completed' => :completed
    }.freeze

    STATES.each do |s|
      define_method(:"#{s}?") do
        state == s
      end
    end

    on Applying::DraftCreated do |event|
      @application_type = event.data.fetch(:entity_type)
      @business_reference = event.data.fetch(:business_reference)
      @active_drafts += 1
      @deletion_at = (event.data.fetch(:created_at, nil) || timestamp(event)) + retention_period
      @last_significant_event_at = timestamp(event)
    end

    on Applying::DraftUpdated do |_event|
      # No action required.
      # Draft application deletion is handled by CrimeApply.
      # The datastore only checks for the existence of drafts and does not
      # process DraftUpdated events.
    end

    on Applying::DraftDeleted do |event|
      @deletion_log_entry = nil
      @active_drafts -= 1
      @last_significant_event_at = timestamp(event)
    end

    on Applying::Submitted do |event|
      @state = :submitted
      @submitted_at = timestamp(event)
      @deletion_at = timestamp(event) + retention_period
      @active_drafts -= 1
      @last_significant_event_at = timestamp(event)
    end

    on Deciding::MaatRecordCreated do |event|
      @maat_ids << event.data.fetch(:maat_id)
      @last_significant_event_at = timestamp(event)
    end

    on Deciding::MaatRecordUpdated do |event|
      @deletion_at = timestamp(event) + retention_period
      @last_significant_event_at = timestamp(event)
    end

    on Deciding::Decided do |event|
      @decision_ids << event.data.fetch(:decision_id)
      @overall_decisions[event.data.fetch(:decision_id)] = event.data.fetch(:overall_decision)
      @state = :decided
      @deletion_at = timestamp(event) + retention_period
      @last_significant_event_at = timestamp(event)
    end

    on Deciding::DecisionUpdated do |event|
      @overall_decisions[event.data.fetch(:decision_id)] = event.data.fetch(:overall_decision)
      @deletion_at = timestamp(event) + retention_period
      @last_significant_event_at = timestamp(event)
    end

    on Reviewing::SentBack do |event|
      @state = :returned
      @returned_at = timestamp(event)
      @reviewed_at = timestamp(event)
      @deletion_at = timestamp(event) + retention_period
      @last_significant_event_at = timestamp(event)
    end

    on Reviewing::Completed do |event|
      @state = :completed
      @reviewed_at = timestamp(event)
      @deletion_at = timestamp(event) + retention_period
      @last_significant_event_at = timestamp(event)
    end

    on Deleting::SoftDeleted do |event|
      @state = :soft_deleted
      @soft_deleted_at = timestamp(event)
      @deletion_at = timestamp(event) + SOFT_DELETION_PERIOD
    end

    on Deleting::HardDeleted do |event|
      @state = :hard_deleted
      @hard_deleted_at = timestamp(event)
      @deletion_reason = event.data.fetch(:reason)
      @deleted_by = event.data.fetch(:deleted_by)
    end

    on Deleting::ExemptFromDeletion do |event|
      @state = :exempt_from_deletion
      @exemption_reason = event.data.fetch(:reason)
      @exempt_until = event.data.fetch(:exempt_until, nil)
      @deletion_at = @exempt_until || (timestamp(event) + retention_period)
      @soft_deleted_at = nil
      @last_significant_event_at = timestamp(event)
    end

    on Deleting::Archived do |event|
      @archived_at = timestamp(event)
      @last_significant_event_at = timestamp(event)
    end

    on Deleting::ApplicationMigrated do |event|
      @state = REVIEW_STATUS_TO_STATE[event.data.fetch(:review_status)]
      @application_type = event.data.fetch(:entity_type)
      @business_reference = event.data.fetch(:business_reference)
      @maat_ids = [event.data.fetch(:maat_id)] if event.data.fetch(:maat_id)
      @decision_ids = [event.data.fetch(:decision_id)] if event.data.fetch(:decision_id)
      if event.data.fetch(:overall_decision)
        @overall_decisions[event.data.fetch(:decision_id)] =
          event.data.fetch(:overall_decision)
      end
      @submitted_at = event.data.fetch(:submitted_at)
      @returned_at = event.data.fetch(:returned_at)
      @reviewed_at = event.data.fetch(:reviewed_at)
      @deletion_at = event.data.fetch(:last_updated_at) + retention_period
      @last_significant_event_at = event.data.fetch(:last_updated_at)
    end

    def initialize
      @active_drafts = 0
      @decision_ids = []
      @overall_decisions = {}
      @maat_ids = []
    end

    def soft_delete(reason:, deleted_by:)
      raise AlreadySoftDeleted if soft_deleted?
      raise CannotSoftDelete unless soft_deletable?

      apply Deleting::SoftDeleted.new(
        data: {
          business_reference: @business_reference,
          reason: reason,
          deleted_by: deleted_by
        }
      )
    end

    def hard_delete(reason:, deleted_by:)
      if hard_deleted?
        Rails.logger.warn("Application #{business_reference} has already been hard deleted")
        raise AlreadyHardDeleted
      end
      raise CannotHardDelete unless hard_deletable?

      apply Deleting::HardDeleted.new(
        data: {
          business_reference: @business_reference,
          reason: reason,
          deleted_by: deleted_by
        }
      )
    end

    def exempt(entity_id:, reason:, exempt_until:)
      raise CannotBeExempt if hard_deleted?

      apply Deleting::ExemptFromDeletion.new(
        data: {
          entity_id: entity_id,
          entity_type: @application_type,
          business_reference: @business_reference,
          reason: reason,
          exempt_until: exempt_until
        }
      )
    end

    def update_maat_record(decision_id:, maat_record:, overall_decision:, updated_at:) # rubocop:disable Metrics/MethodLength
      apply Deciding::MaatRecordUpdated.new(
        data: {
          business_reference: @business_reference,
          maat_record: maat_record.as_json
        },
        metadata: {
          timestamp: updated_at
        }
      )

      return if overall_decision == @overall_decisions[decision_id]

      apply Deciding::DecisionUpdated.new(
        data: {
          business_reference: @business_reference,
          decision_id: decision_id,
          overall_decision: overall_decision
        },
        metadata: {
          timestamp: updated_at
        }
      )
    end

    def soft_deletable?
      return false unless returned? || refused?
      return false if active_drafts?

      @deletion_at <= Time.zone.now
    end

    def hard_deletable?
      return false if @soft_deleted_at.nil?

      @deletion_at <= Time.zone.now
    end

    def maat_check_required?
      return false unless completed_without_decision? || refused? || granted?
      return false if active_drafts? || hard_deletable?

      @deletion_at <= Time.zone.now
    end

    def never_submitted?
      @submitted_at.nil?
    end

    def active_drafts?
      @active_drafts.positive?
    end

    private

    def timestamp(event)
      event.timestamp || Time.zone.now
    end

    def retention_period
      return 2.years if never_submitted?
      return 2.years if returned?
      return 7.years if granted?
      return 3.years if refused?
      return 3.years if completed_without_decision?

      2.years
    end

    def completed_without_decision?
      completed? && @decision_ids.empty?
    end

    # all decisions must be refused to be considered refused for retention purposes
    def refused?
      return false if @overall_decisions.empty?

      @overall_decisions.values.all? { |od| od.starts_with?('refused') }
    end

    # any decision may be granted to be considdered granted for retention purposes
    def granted?
      return false if @overall_decisions.empty?

      @overall_decisions.values.any? { |od| od.starts_with?('granted') }
    end
  end
end
