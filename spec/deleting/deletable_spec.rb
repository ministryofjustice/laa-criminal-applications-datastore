require 'rails_helper'

RSpec.describe Deleting::Deletable do
  subject(:deletable) { described_class.new }

  let(:business_reference) { 'LAA-123456' }
  let(:entity_type) { 'CrimeApplication' }
  let(:created_at) { Time.zone.now }
  let(:maat_id) { 123_456 }
  let(:decision_id) { 'decision-uuid' }

  describe 'state predicates' do
    described_class::STATES.each do |state|
      it "responds to #{state}?" do
        expect(deletable).to respond_to(:"#{state}?")
      end
    end
  end

  describe 'on Applying::DraftCreated' do
    let(:event) do
      Applying::DraftCreated.new(
        data: {
          entity_type:,
          business_reference:,
          created_at:
        }
      )
    end

    before { deletable.apply(event) }

    it 'sets the business reference' do
      expect(deletable.business_reference).to eq(business_reference)
    end

    it 'increments active drafts' do
      expect(deletable.active_drafts?).to be true
    end

    it 'sets deletion_at to created_at plus retention period' do
      expect(deletable.deletion_at).to eq(created_at + 2.years)
    end
  end

  describe 'on Applying::DraftUpdated' do
    it 'does not change state' do
      event = Applying::DraftUpdated.new(data: {})
      expect { deletable.apply(event) }.not_to change(deletable, :state)
    end
  end

  describe 'on Applying::DraftDeleted' do
    before do
      deletable.apply(Applying::DraftCreated.new(
                        data: {
                          entity_type:,
                          business_reference:
                        }
                      ))
    end

    it 'decrements active drafts' do
      expect { deletable.apply(Applying::DraftDeleted.new(data: {})) }
        .to change(deletable, :active_drafts?).from(true).to(false)
    end
  end

  describe 'on Applying::Submitted' do
    let(:submitted_at) { Time.zone.now }
    let(:event) do
      Applying::Submitted.new(data: {}).tap do |e|
        allow(e).to receive(:timestamp).and_return(submitted_at)
      end
    end

    before do
      deletable.apply(Applying::DraftCreated.new(
                        data: {
                          entity_type:,
                          business_reference:
                        }
                      ))
      deletable.apply(event)
    end

    it 'sets state to submitted' do
      expect(deletable).to be_submitted
    end

    it 'decrements active drafts' do
      expect(deletable.active_drafts?).to be false
    end

    it 'sets deletion_at based on submitted_at' do
      expect(deletable.deletion_at).to eq(submitted_at + 2.years)
    end
  end

  describe 'on Deciding::MaatRecordCreated' do
    let(:event) do
      Deciding::MaatRecordCreated.new(data: { maat_id: })
    end

    it 'stores the maat_id' do
      deletable.apply(event)
      expect(deletable.instance_variable_get(:@maat_ids)).to eq([maat_id])
    end
  end

  describe 'on Deciding::Decided' do
    let(:submitted_at) { 1.year.ago }
    let(:decided_at) { Time.zone.now }

    before do
      # Submit the application first so retention period calculation works correctly
      deletable.apply(Applying::Submitted.new(data: {}).tap do |e|
        allow(e).to receive(:timestamp).and_return(submitted_at)
      end)
    end

    context 'with a single granted decision' do
      let(:event) do
        Deciding::Decided.new(
          data: {
            decision_id: decision_id,
            overall_decision: 'granted_on_all_counts'
          }
        ).tap do |e|
          allow(e).to receive(:timestamp).and_return(decided_at)
        end
      end

      before { deletable.apply(event) }

      it 'sets state to decided' do
        expect(deletable).to be_decided
      end

      it 'sets deletion_at to decided_at plus retention period for granted' do
        expect(deletable.deletion_at).to eq(decided_at + 7.years)
      end
    end

    context 'with multiple decisions where one is granted' do
      let(:first_decision_at) { 2.days.ago }
      let(:second_decision_at) { Time.zone.now }

      before do
        deletable.apply(Deciding::Decided.new(
          data: {
            decision_id: 'decision-1',
            overall_decision: 'refused_ineligible'
          }
        ).tap { |e| allow(e).to receive(:timestamp).and_return(first_decision_at) })

        deletable.apply(Deciding::Decided.new(
          data: {
            decision_id: 'decision-2',
            overall_decision: 'granted_with_contributions'
          }
        ).tap { |e| allow(e).to receive(:timestamp).and_return(second_decision_at) })
      end

      it 'sets state to decided' do
        expect(deletable).to be_decided
      end

      it 'sets deletion_at to last decision time plus retention period for granted' do
        expect(deletable.deletion_at).to eq(second_decision_at + 7.years)
      end

      it 'has granted? return true' do
        expect(deletable.send(:granted?)).to be true
      end
    end

    context 'with multiple decisions all refused' do
      let(:first_decision_at) { 2.days.ago }
      let(:second_decision_at) { Time.zone.now }

      before do
        deletable.apply(Deciding::Decided.new(
          data: {
            decision_id: 'decision-1',
            overall_decision: 'refused_ineligible'
          }
        ).tap { |e| allow(e).to receive(:timestamp).and_return(first_decision_at) })

        deletable.apply(Deciding::Decided.new(
          data: {
            decision_id: 'decision-2',
            overall_decision: 'refused_failed_means'
          }
        ).tap { |e| allow(e).to receive(:timestamp).and_return(second_decision_at) })
      end

      it 'sets state to decided' do
        expect(deletable).to be_decided
      end

      it 'sets deletion_at to last decision time plus retention period for refused' do
        expect(deletable.deletion_at).to eq(second_decision_at + 3.years)
      end

      it 'has refused? return true' do
        expect(deletable.send(:refused?)).to be true
      end

      it 'has granted? return false' do
        expect(deletable.send(:granted?)).to be false
      end
    end
  end

  describe 'on Reviewing::SentBack' do
    let(:returned_at) { Time.zone.now }
    let(:event) do
      Reviewing::SentBack.new(data: {}).tap do |e|
        allow(e).to receive(:timestamp).and_return(returned_at)
      end
    end

    before { deletable.apply(event) }

    it 'sets state to returned' do
      expect(deletable).to be_returned
    end

    it 'sets deletion_at to returned_at plus retention period' do
      expect(deletable.deletion_at).to eq(returned_at + 2.years)
    end
  end

  describe 'on Reviewing::Completed' do
    let(:submitted_at) { 1.year.ago }
    let(:reviewed_at) { Time.zone.now }
    let(:event) do
      Reviewing::Completed.new(data: {}).tap do |e|
        allow(e).to receive(:timestamp).and_return(reviewed_at)
      end
    end

    before do
      # Submit the application first so retention period calculation works correctly
      deletable.apply(Applying::Submitted.new(data: {}).tap do |e|
        allow(e).to receive(:timestamp).and_return(submitted_at)
      end)
      deletable.apply(event)
    end

    it 'sets state to completed' do
      expect(deletable).to be_completed
    end

    it 'sets deletion_at based on reviewed_at' do
      expect(deletable.deletion_at).to eq(reviewed_at + 3.years)
    end
  end

  describe 'on Deleting::SoftDeleted' do
    let(:soft_deleted_at) { Time.zone.now }
    let(:event) do
      Deleting::SoftDeleted.new(
        data: {
          business_reference: business_reference,
          reason: 'Test reason',
          deleted_by: 'system'
        }
      ).tap do |e|
        allow(e).to receive(:timestamp).and_return(soft_deleted_at)
      end
    end

    before { deletable.apply(event) }

    it 'sets state to soft_deleted' do
      expect(deletable).to be_soft_deleted
    end

    it 'sets soft_deleted_at timestamp' do
      expect(deletable.soft_deleted_at).to eq(soft_deleted_at)
    end

    it 'sets deletion_at to soft_deleted_at plus SOFT_DELETION_PERIOD' do
      expect(deletable.deletion_at).to eq(soft_deleted_at + Deleting::SOFT_DELETION_PERIOD)
    end
  end

  describe 'on Deleting::HardDeleted' do
    let(:hard_deleted_at) { Time.zone.now }
    let(:event) do
      Deleting::HardDeleted.new(
        data: {
          reason: 'Test hard delete',
          deleted_by: 'system'
        }
      ).tap do |e|
        allow(e).to receive(:timestamp).and_return(hard_deleted_at)
      end
    end

    before { deletable.apply(event) }

    it 'sets state to hard_deleted' do
      expect(deletable).to be_hard_deleted
    end
  end

  describe 'on Deleting::ExemptFromDeletion' do
    let(:exempt_until) { 1.year.from_now }
    let(:exempt_at) { Time.zone.now }
    let(:event) do
      Deleting::ExemptFromDeletion.new(
        data: {
          reason: 'Legal hold',
          exempt_until: exempt_until
        }
      ).tap do |e|
        allow(e).to receive(:timestamp).and_return(exempt_at)
      end
    end

    before { deletable.apply(event) }

    it 'sets state to exempt_from_deletion' do
      expect(deletable).to be_exempt_from_deletion
    end

    it 'sets deletion_at to exempt_until' do
      expect(deletable.deletion_at).to eq(exempt_until)
    end

    it 'clears soft_deleted_at' do
      expect(deletable.soft_deleted_at).to be_nil
    end

    context 'when exempt_until is nil' do
      let(:event) do
        Deleting::ExemptFromDeletion.new(
          data: {
            reason: 'Legal hold',
            exempt_until: nil
          }
        ).tap do |e|
          allow(e).to receive(:timestamp).and_return(exempt_at)
        end
      end

      it 'sets deletion_at to timestamp plus retention period' do
        expect(deletable.deletion_at).to be_within(1.second).of(exempt_at + 2.years)
      end
    end
  end

  describe 'on Deleting::ApplicationMigrated' do
    let(:submitted_at) { 1.year.ago }
    let(:last_updated_at) { 6.months.ago }
    let(:event) do
      Deleting::ApplicationMigrated.new(
        data: {
          review_status: 'assessment_completed',
          entity_type: entity_type,
          business_reference: business_reference,
          maat_id: maat_id,
          decision_id: decision_id,
          overall_decision: 'granted',
          submitted_at: submitted_at,
          returned_at: nil,
          reviewed_at: last_updated_at,
          last_updated_at: last_updated_at
        }
      )
    end

    before { deletable.apply(event) }

    it 'sets state based on review_status' do
      expect(deletable).to be_completed
    end

    it 'sets business_reference' do
      expect(deletable.business_reference).to eq(business_reference)
    end

    it 'sets deletion_at based on last_updated_at plus retention period' do
      expect(deletable.deletion_at).to eq(last_updated_at + 7.years)
    end
  end

  describe '#soft_delete' do
    let(:reason) { 'retention_rule' }

    context 'when application is returned and eligible' do
      before do
        deletable.apply(Applying::DraftCreated.new(
          data: {
            entity_type:,
            business_reference:
          }
        ).tap { |e| allow(e).to receive(:timestamp).and_return(3.years.ago) })

        deletable.apply(Applying::Submitted.new(data: {})
          .tap { |e| allow(e).to receive(:timestamp).and_return(3.years.ago) })

        deletable.apply(Reviewing::SentBack.new(data: {})
          .tap { |e| allow(e).to receive(:timestamp).and_return(3.years.ago) })
      end

      it 'applies SoftDeleted event' do
        expect { deletable.soft_delete(reason: reason, deleted_by: 'system') }
          .to change(deletable, :soft_deleted?).from(false).to(true)
      end
    end

    context 'when not soft deletable' do
      before do
        deletable.instance_variable_set(:@soft_deleted_at, nil)
      end

      it 'raises CannotHardDelete error' do
        expect { deletable.soft_delete(reason: reason, deleted_by: 'system') }
          .to raise_error(described_class::CannotSoftDelete)
      end
    end

    context 'when already soft deleted' do
      before do
        deletable.instance_variable_set(:@state, :soft_deleted)
      end

      it 'raises AlreadySoftDeleted error' do
        expect { deletable.soft_delete(reason: reason, deleted_by: 'system') }
          .to raise_error(described_class::AlreadySoftDeleted)
      end
    end
  end

  describe '#hard_delete' do
    let(:reason) { 'Soft deletion period expired' }

    context 'when already hard deleted' do
      before do
        deletable.instance_variable_set(:@state, :hard_deleted)
      end

      it 'raises AlreadyHardDeleted error' do
        expect { deletable.hard_delete(reason: reason, deleted_by: 'system') }
          .to raise_error(described_class::AlreadyHardDeleted)
      end
    end

    context 'when not hard deletable' do
      before do
        deletable.instance_variable_set(:@soft_deleted_at, nil)
      end

      it 'raises CannotHardDelete error' do
        expect { deletable.hard_delete(reason: reason, deleted_by: 'system') }
          .to raise_error(described_class::CannotHardDelete)
      end
    end

    context 'when hard deletable' do
      before do
        deletable.instance_variable_set(:@soft_deleted_at, 3.months.ago)
        deletable.instance_variable_set(:@deletion_at, 1.day.ago)
      end

      it 'applies HardDeleted event' do
        expect { deletable.hard_delete(reason: reason, deleted_by: 'system') }
          .to change(deletable, :hard_deleted?).from(false).to(true)
      end
    end
  end

  describe '#exempt' do
    let(:entity_id) { 'uuid-123' }
    let(:reason) { 'Legal hold' }
    let(:exempt_until) { 1.year.from_now }

    before do
      deletable.instance_variable_set(:@application_type, entity_type)
      deletable.instance_variable_set(:@business_reference, business_reference)
    end

    context 'when not hard deleted' do
      it 'applies ExemptFromDeletion event' do
        expect { deletable.exempt(entity_id:, reason:, exempt_until:) }
          .to change(deletable, :exempt_from_deletion?).from(false).to(true)
      end
    end

    context 'when hard deleted' do
      before do
        deletable.instance_variable_set(:@state, :hard_deleted)
      end

      it 'raises CannotBeExempt error' do
        expect { deletable.exempt(entity_id:, reason:, exempt_until:) }
          .to raise_error(Deleting::Deletable::CannotBeExempt)
      end
    end
  end

  describe '#soft_deletable?' do
    before do
      deletable.instance_variable_set(:@business_reference, business_reference)
      deletable.instance_variable_set(:@maat_ids, nil)
    end

    context 'when not returned' do
      before { deletable.instance_variable_set(:@state, :submitted) }

      it 'returns false' do
        expect(deletable.soft_deletable?).to be false
      end
    end

    context 'when returned but has active drafts' do
      before do
        deletable.instance_variable_set(:@state, :returned)
        deletable.instance_variable_set(:@active_drafts, 1)
        deletable.instance_variable_set(:@deletion_at, 1.day.ago)
      end

      it 'returns false' do
        expect(deletable.soft_deletable?).to be false
      end
    end

    context 'when returned, no active drafts, deletion_at passed' do
      before do
        deletable.instance_variable_set(:@state, :returned)
        deletable.instance_variable_set(:@active_drafts, 0)
        deletable.instance_variable_set(:@deletion_at, 1.day.ago)
      end

      it 'returns true' do
        expect(deletable.soft_deletable?).to be true
      end
    end
  end

  describe '#hard_deletable?' do
    context 'when soft_deleted_at is nil' do
      before { deletable.instance_variable_set(:@soft_deleted_at, nil) }

      it 'returns false' do
        expect(deletable.hard_deletable?).to be false
      end
    end

    context 'when deletion_at has not passed' do
      before do
        deletable.instance_variable_set(:@soft_deleted_at, 1.month.ago)
        deletable.instance_variable_set(:@deletion_at, 1.day.from_now)
      end

      it 'returns false' do
        expect(deletable.hard_deletable?).to be false
      end
    end

    context 'when soft_deleted_at is set and deletion_at has passed' do
      before do
        deletable.instance_variable_set(:@soft_deleted_at, 1.month.ago)
        deletable.instance_variable_set(:@deletion_at, 1.day.ago)
      end

      it 'returns true' do
        expect(deletable.hard_deletable?).to be true
      end
    end
  end

  describe '#never_submitted?' do
    context 'when submitted_at is nil' do
      it 'returns true' do
        expect(deletable.never_submitted?).to be true
      end
    end

    context 'when submitted_at is set' do
      before { deletable.instance_variable_set(:@submitted_at, Time.zone.now) }

      it 'returns false' do
        expect(deletable.never_submitted?).to be false
      end
    end
  end

  describe '#active_drafts?' do
    context 'when active_drafts is zero' do
      it 'returns false' do
        expect(deletable.active_drafts?).to be false
      end
    end

    context 'when active_drafts is positive' do
      before { deletable.instance_variable_set(:@active_drafts, 1) }

      it 'returns true' do
        expect(deletable.active_drafts?).to be true
      end
    end
  end
end
