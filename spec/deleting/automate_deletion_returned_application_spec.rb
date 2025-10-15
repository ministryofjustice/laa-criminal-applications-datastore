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

  before do
    travel_to current_date
  end

  describe 'Returned application' do
    context 'when sent back 2 years ago and not injected into MAAT' do
      let(:events) do
        [
          Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftDeleted, Time.zone.local(2023, 9, 1), { entity_id: entity_id, entity_type: entity_type,
                                                                  business_reference: business_reference,
                                                                  reason: 'provider_action',
                                                                  deleted_by: SecureRandom.uuid },
          Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id:, entity_type:, business_reference: },
          Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: entity_id, entity_type: entity_type,
                                                              business_reference: business_reference,
                                                              reason: 'duplicate_application' }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2023, 9, 4))
      end

      before do
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'publishes a SoftDeleted event' do
        soft_deleted_events = events_in_stream.of_type([Deleting::SoftDeleted]).to_a
        expect(soft_deleted_events.count).to eq(1)
        expect(soft_deleted_events.first.data).to eq(
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            reason: Types::DeletionReason['retention_rule'],
            deleted_by: 'system_automated'
          }
        )
      end

      it 'pushes the `review_deletion_at` timestamp on the read model back by two weeks' do
        expect(deletable_entity.reload.review_deletion_at).to eq(current_date + 2.weeks)
      end

      it 'sets `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_within(2.seconds).of(Time.zone.now)
      end

      context 'when two weeks have passed' do
        before do
          travel_to current_date + 2.weeks
          automate_deletion.call
        end

        it 'does not publish another SoftDeleted event' do
          expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(1)
        end

        it 'publishes a HardDeleted event' do
          hard_deleted_events = events_in_stream.of_type([Deleting::HardDeleted]).to_a
          expect(hard_deleted_events.count).to eq(1)
          expect(hard_deleted_events.first.data).to eq(
            {
              entity_id: entity_id,
              entity_type: entity_type,
              business_reference: business_reference,
              deletion_entry_id: DeletionEntry.first.id,
            }
          )
        end

        it 'creates a deletion record' do
          expect(DeletionEntry.first).to have_attributes(
            {
              record_id: entity_id,
              record_type: Types::RecordType['application'],
              business_reference: business_reference.to_s,
              deleted_by: 'system_automated',
              reason: Types::DeletionReason['retention_rule']
            }
          )
        end

        it 'removes deletable_entities record' do
          expect(DeletableEntity.find_by(business_reference:)).to be_nil
        end
      end
    end

    context 'when sent back 2 years ago, not injected into MAAT and migrated' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:submitted_at) { Time.zone.local(2023, 9, 3) }
      let(:returned_at) { Time.zone.local(2023, 9, 4) }
      let(:reviewed_at) { Time.zone.local(2023, 9, 4) }
      let(:last_updated_at) { Time.zone.local(2023, 9, 4) }
      let(:review_status) { 'returned_to_provider' }
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
            submitted_at: submitted_at,
            returned_at: returned_at,
            reviewed_at: reviewed_at,
            last_updated_at: last_updated_at,
            review_status: review_status
          }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: last_updated_at + 2.years)
      end

      before do
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'publishes a SoftDeleted event' do
        soft_deleted_events = events_in_stream.of_type([Deleting::SoftDeleted]).to_a
        expect(soft_deleted_events.count).to eq(1)
        expect(soft_deleted_events.first.data).to eq(
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            reason: Types::DeletionReason['retention_rule'],
            deleted_by: 'system_automated'
          }
        )
      end

      it 'pushes the `review_deletion_at` timestamp on the read model back by two weeks' do
        expect(deletable_entity.reload.review_deletion_at).to eq(current_date + 2.weeks)
      end

      it 'sets `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_within(2.seconds).of(Time.zone.now)
      end

      context 'when two weeks have passed' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        before do
          travel_to current_date + 2.weeks
          automate_deletion.call
        end

        it 'does not publish another SoftDeleted event' do
          expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(1)
        end

        it 'publishes a HardDeleted event' do
          hard_deleted_events = events_in_stream.of_type([Deleting::HardDeleted]).to_a
          expect(hard_deleted_events.count).to eq(1)
          expect(hard_deleted_events.first.data).to eq(
            {
              entity_id: entity_id,
              entity_type: entity_type,
              business_reference: business_reference,
              deletion_entry_id: DeletionEntry.first.id,
            }
          )
        end

        it 'creates a deletion record' do
          expect(DeletionEntry.first).to have_attributes(
            {
              record_id: entity_id,
              record_type: Types::RecordType['application'],
              business_reference: business_reference.to_s,
              deleted_by: 'system_automated',
              reason: Types::DeletionReason['retention_rule']
            }
          )
        end

        it 'removes deletable_entities record' do
          expect(DeletableEntity.find_by(business_reference:)).to be_nil
        end
      end
    end

    context 'when sent back 2 years ago and was injected into MAAT' do
      let(:events) do
        [
          Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftDeleted, Time.zone.local(2023, 9, 1), { entity_id: entity_id, entity_type: entity_type,
                                                                  business_reference: business_reference,
                                                                  reason: 'provider_action',
                                                                  deleted_by: SecureRandom.uuid },
          Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id:, entity_type:, business_reference: },
          Deciding::MaatRecordCreated, Time.zone.local(2023, 9, 2), { entity_id:, entity_type:, business_reference:,
                                                                      maat_id: },
          Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: entity_id, entity_type: entity_type,
                                                              business_reference: business_reference,
                                                              reason: 'duplicate_application' }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2023, 9, 4))
      end

      before do
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 4) + 2.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end

    context 'when sent back 2 years ago, injected into MAAT and migrated' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:submitted_at) { Time.zone.local(2023, 9, 3) }
      let(:returned_at) { Time.zone.local(2023, 9, 4) }
      let(:reviewed_at) { Time.zone.local(2023, 9, 4) }
      let(:last_updated_at) { Time.zone.local(2023, 9, 4) }
      let(:review_status) { 'returned_to_provider' }
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
            submitted_at: submitted_at,
            returned_at: returned_at,
            reviewed_at: reviewed_at,
            last_updated_at: last_updated_at,
            review_status: review_status
          }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: last_updated_at + 2.years)
      end

      before do
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 4) + 2.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end

    context 'when sent back 2 years ago and has active drafts' do
      let(:events) do
        [
          Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
          Applying::DraftDeleted, Time.zone.local(2023, 9, 1), { entity_id: entity_id, entity_type: entity_type,
                                                                  business_reference: business_reference,
                                                                  reason: 'provider_action',
                                                                  deleted_by: SecureRandom.uuid },
          Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id:, entity_type:, business_reference: },
          Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: entity_id, entity_type: entity_type,
                                                              business_reference: business_reference,
                                                              reason: 'duplicate_application' },
          Applying::DraftCreated, Time.zone.local(2023, 9, 5), { entity_id:, entity_type:, business_reference: }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2023, 9, 5))
      end

      before do
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 5) + 2.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end

    context 'when sent back 2 years ago, has active drafts and migrated' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:submitted_at) { Time.zone.local(2023, 9, 3) }
      let(:returned_at) { Time.zone.local(2023, 9, 4) }
      let(:reviewed_at) { Time.zone.local(2023, 9, 4) }
      let(:last_updated_at) { Time.zone.local(2023, 9, 4) }
      let(:review_status) { 'returned_to_provider' }
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
            submitted_at: submitted_at,
            returned_at: returned_at,
            reviewed_at: reviewed_at,
            last_updated_at: last_updated_at,
            review_status: review_status
          },
          Applying::DraftCreated, current_date,
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            created_at: Time.zone.local(2023, 9, 3)
          },
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: last_updated_at + 2.years)
      end

      before do
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 3) + 2.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end
  end
end
