module Deleting
  class Deletable # rubocop:disable Metrics/ClassLength
    include AggregateRoot
    class AlreadySoftDeleted < StandardError; end
    class AlreadyHardDeleted < StandardError; end
    class CannotBeExempt < StandardError; end

    attr_reader :business_reference, :deletion_at, :state

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
    end

    on Applying::DraftUpdated do |event|
      @deletion_at = timestamp(event) + retention_period
    end

    on Applying::DraftDeleted do |_event|
      @deletion_log_entry = nil
      @active_drafts -= 1
    end

    on Applying::Submitted do |event|
      @state = :submitted
      @submitted_at = timestamp(event)
      @deletion_at = timestamp(event) + retention_period
    end

    on Deciding::MaatRecordCreated do |event|
      @maat_id = event.data.fetch(:maat_id)
    end

    on Deciding::Decided do |event|
      @decision_id = event.data.fetch(:decision_id)
      @overall_decision = event.data.fetch(:overall_decision)
      @state = :decided
      @deletion_at = timestamp(event) + retention_period
    end

    on Reviewing::SentBack do |event|
      @state = :returned
      @returned_at = timestamp(event)
      @reviewed_at = timestamp(event)
      @deletion_at = timestamp(event) + retention_period
    end

    on Reviewing::Completed do |event|
      @state = :completed
      @reviewed_at = timestamp(event)
      @deletion_at = timestamp(event) + retention_period
    end

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

    on Deleting::ExemptFromDeletion do |event|
      @state = :exempt_from_deletion
      @exemption_reason = event.data.fetch(:reason)
      @exempt_until = event.data.fetch(:exempt_until, nil)
      @deletion_at = @exempt_until || (timestamp(event) + retention_period)
    end

    on Deleting::ApplicationMigrated do |event|
      @state = REVIEW_STATUS_TO_STATE[event.data.fetch(:review_status)]
      @application_type = event.data.fetch(:entity_type)
      @business_reference = event.data.fetch(:business_reference)
      @maat_id = event.data.fetch(:maat_id)
      @decision_id = event.data.fetch(:decision_id)
      @overall_decision = event.data.fetch(:overall_decision)
      @submitted_at = event.data.fetch(:submitted_at)
      @returned_at = event.data.fetch(:returned_at)
      @reviewed_at = event.data.fetch(:reviewed_at)
      @deletion_at = event.data.fetch(:last_updated_at) + retention_period
    end

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

    def soft_deletable?
      return false unless returned?
      return false if active_drafts?

      @deletion_at <= Time.zone.now && !injected_into_maat
    end

    def hard_deletable?
      return false if @soft_deleted_at.nil?

      @deletion_at <= Time.zone.now
    end

    private

    def active_drafts?
      @active_drafts.positive?
    end

    def injected_into_maat
      @maat_id.present?
    end

    def timestamp(event)
      event.timestamp || Time.zone.now
    end

    def retention_period
      return 2.years if never_submitted?
      return 2.years if returned?
      return 3.years if completed_without_decision?
      return 3.years if refused?
      return 7.years if granted?

      2.years
    end

    def never_submitted?
      @submitted_at.nil?
    end

    def completed_without_decision?
      completed? && @decision_id.blank?
    end

    def refused?
      @overall_decision.present? && @overall_decision.starts_with?('refused')
    end

    def granted?
      @overall_decision.present? && @overall_decision.starts_with?('granted')
    end
  end
end
