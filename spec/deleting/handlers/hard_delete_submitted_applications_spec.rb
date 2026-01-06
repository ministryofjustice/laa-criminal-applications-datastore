require 'rails_helper'

RSpec.describe Deleting::Handlers::HardDeleteSubmittedApplications do
  describe '#call' do
    let(:handler) { described_class.new }
    let(:business_reference) { 6_000_001 }
    let(:deleted_by) { 'system_automated' }
    let(:reason) { 'retention_rule' }
    let(:correlation_id) { SecureRandom.uuid }
    let(:event) do
      Deleting::HardDeleted.new(
        data: { business_reference:, reason:, deleted_by: },
        metadata: { correlation_id: }
      )
    end

    let(:applications) do
      first = CrimeApplication.create!(
        submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
      )
      second = CrimeApplication.create!(
        submitted_application: JSON.parse(
          LaaCrimeSchemas.fixture(1.0).read
        ).merge({ 'id' => SecureRandom.uuid, 'parent_id' => first.id }),
      )
      pse = CrimeApplication.create!(
        submitted_application: JSON.parse(
          LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read
        ).merge({ 'parent_id' => second.id })
      )

      [first, second, pse]
    end

    before do
      # create an application that should not be deleted
      CrimeApplication.create!(
        submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge({ 'id' => SecureRandom.uuid,
'reference' => 6_000_022 })
      )

      applications.each { |a| a.update(soft_deleted_at: 30.days.ago) }

      allow(DeletionEntry).to receive(:create!)
    end

    it 'raise an error if event is not HardDeleted' do
      expect { handler.call(Deleting::SoftDeleted.new) }.to raise_error Deleting::UnexpectedEventType
    end

    it 'anonymises all CrimeApplications for the given business reference' do
      expect { handler.call(event) }.to change {
        CrimeApplication.pluck(:applicant_last_name).sort
      }.to(['Pound', '[deleted]', '[deleted]', '[deleted]'])
      # 'Pound' is the last name of the unrelated application
    end

    it 'persists a deletion entry for each anonymised application' do
      allow(DeletionEntry).to receive(:create!).and_call_original
      expect { handler.call(event) }.to change {
        DeletionEntry.where(
          business_reference:, correlation_id:, deleted_by:, reason:,
        ).count
      }.from(0).to(3)
    end

    it 'correctly sets DeletionEntry attributes for each anonymised application' do
      handler.call(event)

      applications.each do |app|
        expect(DeletionEntry).to have_received(:create!).with(
          record_id: app.id,
          record_type: Types::RecordType['application'],
          business_reference: business_reference,
          deleted_by: deleted_by,
          deleted_from: Types::RecordSource['criminal_applications_datastore'],
          reason: reason,
          correlation_id: correlation_id
        )
      end
    end

    it 'does not create a deletion entry if already hard deleted' do
      applications.each { |a| a.update(hard_deleted_at: Time.current) }
      handler.call(event)

      expect(DeletionEntry).not_to have_received(:create!)
    end

    context 'when a crime applications has not yet been soft deleted' do
      before do
        applications.first.update(soft_deleted_at: nil)
      end

      it 'raises an Errors::NotSoftDeleted error' do
        expect { handler.call(event) }.to raise_error Errors::NotSoftDeleted
      end
    end
  end
end
