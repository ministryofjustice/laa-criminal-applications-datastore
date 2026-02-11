require 'rails_helper'

RSpec.describe Deleting::AutomateDeletion do
  subject(:automate_deletion) { described_class }

  include_context 'with published events'

  let!(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end
  let(:entity_id) { crime_application.id }
  let(:business_reference) { crime_application.reference }
  let(:entity_type) { crime_application.application_type }
  let(:maat_id) { '987654321' }
  let(:event_stream) { "Deleting$#{business_reference}" }
  let(:current_date) { Time.zone.local(2025, 9, 6) }
  let(:soft_deleted_event) { instance_double(Events::SoftDeletion, publish: true) }

  before do
    travel_to current_date
  end

  describe 'Completed application' do
    context 'when completed 2 years ago, injected into MAAT and migrated' do
      let(:events) do
        [
          Deleting::ApplicationMigrated, current_date,
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            maat_id: maat_id,
            decision_id: nil,
            overall_decision: nil,
            submitted_at: Time.zone.local(2023, 9, 3),
            returned_at: nil,
            reviewed_at: Time.zone.local(2023, 9, 4),
            last_updated_at: Time.zone.local(2023, 9, 4),
            review_status: 'assessment_completed'
          }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2023, 9, 4))
      end

      before do
        allow(Events::SoftDeletion).to receive(:new).with(crime_application).and_return(soft_deleted_event)

        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not publish a soft deleted sns event' do
        expect(soft_deleted_event).not_to have_received(:publish)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 4) + 3.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end

    context 'when completed 2 years ago, not injected into MAAT and migrated' do
      let(:events) do
        [
          Deleting::ApplicationMigrated, current_date,
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            maat_id: nil,
            decision_id: nil,
            overall_decision: nil,
            submitted_at: Time.zone.local(2023, 9, 3),
            returned_at: nil,
            reviewed_at: Time.zone.local(2023, 9, 4),
            last_updated_at: Time.zone.local(2023, 9, 4),
            review_status: 'assessment_completed'
          }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2023, 9, 4))
      end

      before do
        allow(Events::SoftDeletion).to receive(:new).with(crime_application).and_return(soft_deleted_event)

        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not publish a soft deleted sns event' do
        expect(soft_deleted_event).not_to have_received(:publish)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 4) + 3.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end
  end
end
