require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Deleting::AutomateDeletion do
  subject(:automate_deletion) { described_class }

  include_context 'with published events'
  include_context 'with an S3 client'

  let!(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end
  let(:entity_id) { crime_application.id }
  let(:business_reference) { crime_application.reference }
  let(:entity_type) { crime_application.application_type }
  let(:maat_id) { 9_874_622 }
  let(:event_stream) { "Deleting$#{business_reference}" }
  let(:current_date) { Time.zone.local(2025, 9, 6) }
  let(:soft_deleted_event) { instance_double(Events::SoftDeleted, publish: true) }
  let(:hard_delete_submitted_applications) { instance_double(Deleting::Handlers::HardDeleteSubmittedApplications) }
  let(:hard_delete_documents) { instance_double(Deleting::Handlers::HardDeleteDocuments) }
  let(:maat_get_record) { instance_double(MAAT::GetRecord) }

  before do
    travel_to current_date
  end

  describe 'Application completed without a decision' do
    context 'when completed 2 years ago' do
      let(:events) do
        [
          Deleting::ApplicationMigrated, Time.zone.local(2023, 9, 4),
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            maat_id: maat_id,
            decision_id: nil,
            overall_decision: nil,
            submitted_at: Time.zone.local(2023, 9, 1),
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
        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'does not publish a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
      end

      it 'does not alter the `review_deletion_at` timestamp on the read model' do
        expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2023, 9, 4) + 3.years)
      end

      it 'does not set `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_nil
      end
    end

    context 'when completed 3 years ago' do
      let(:events) do
        [
          Deleting::ApplicationMigrated, Time.zone.local(2022, 9, 4),
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            maat_id: maat_id,
            decision_id: nil,
            overall_decision: nil,
            submitted_at: Time.zone.local(2022, 9, 1),
            returned_at: nil,
            reviewed_at: Time.zone.local(2022, 9, 4),
            last_updated_at: Time.zone.local(2022, 9, 4),
            review_status: 'assessment_completed'
          }
        ]
      end
      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2022, 9, 4))
      end
      let(:maat_record) { nil }

      before do
        allow(Events::SoftDeleted).to receive(:new)
          .with(reference: crime_application.reference, soft_deleted_at: current_date)
          .and_return(soft_deleted_event)
        allow(Deleting::Handlers::HardDeleteDocuments).to receive(:new) {
          hard_delete_submitted_applications
        }
        allow(Deleting::Handlers::HardDeleteSubmittedApplications).to receive(:new) {
          hard_delete_documents
        }
        allow(hard_delete_documents).to receive(:call)
        allow(hard_delete_submitted_applications).to receive(:call)
        allow(MAAT::GetRecord).to receive(:new).and_return(maat_get_record)
        allow(maat_get_record).to receive(:by_maat_id!) do
          raise MAAT::RecordNotFound if maat_record.nil?

          maat_record
        end

        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      context 'without new updates in MAAT' do
        let(:maat_record) do
          MAAT::Record.new(
            maat_ref: maat_id,
            usn: business_reference,
            ioj_result: 'PASS',
            ioj_assessor_name: 'Jo Bloggs',
            app_created_date: Time.zone.local(2022, 9, 4).as_json,
            means_result: 'FAIL',
            means_assessor_name: 'Jo Bloggs',
            date_means_created: Time.zone.local(2022, 9, 4).as_json,
            funding_decision: 'FAILMEANS'
          )
        end

        it 'calls MAAT' do
          expect(maat_get_record).to have_received(:by_maat_id!).with(maat_id).once
        end

        it 'does not publish a MaatRecordUpdated event' do
          expect(events_in_stream.of_type([Deciding::MaatRecordUpdated]).count).to eq(0)
        end

        it 'does not publish a DecisionUpdated event' do
          expect(events_in_stream.of_type([Deciding::DecisionUpdated]).count).to eq(0)
        end

        it 'does not publish a SoftDeleted event' do
          expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
        end

        it 'does not publish a soft deleted sns event' do
          expect(soft_deleted_event).not_to have_received(:publish)
        end

        it 'does not alter the `review_deletion_at` timestamp on the read model' do
          expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2022, 9, 4) + 3.years)
        end

        it 'does not set `soft_deleted_at` on the application' do
          expect(crime_application.reload.soft_deleted_at).to be_nil
        end
      end

      context 'with a refused decision in MAAT' do
        let(:maat_record) do
          MAAT::Record.new(
            maat_ref: maat_id,
            usn: business_reference,
            ioj_result: 'PASS',
            ioj_assessor_name: 'Jo Bloggs',
            app_created_date: Time.zone.local(2022, 9, 4).as_json,
            means_result: 'FAIL',
            means_assessor_name: 'Jo Bloggs',
            date_means_created: Time.zone.local(2022, 9, 5).as_json,
            funding_decision: 'FAILMEANS'
          )
        end

        it 'calls MAAT' do
          expect(maat_get_record).to have_received(:by_maat_id!).with(maat_id).once
        end

        it 'publishes a MaatRecordUpdated event' do
          maat_record_updated_events = events_in_stream.of_type([Deciding::MaatRecordUpdated])
          expect(maat_record_updated_events.count).to eq(1)
          expect(maat_record_updated_events.first.data).to eq(
            {
              business_reference: business_reference,
              maat_record: maat_record.as_json
            }
          )
        end

        it 'publishes a DecisionUpdated event' do
          decision_updated_events = events_in_stream.of_type([Deciding::DecisionUpdated])
          expect(decision_updated_events.count).to eq(1)
          expect(decision_updated_events.first.data).to eq(
            {
              business_reference: business_reference,
              decision_id: maat_id,
              overall_decision: 'refused_failed_means'
            }
          )
        end

        it 'publishes a SoftDeleted event' do
          soft_deleted_events = events_in_stream.of_type([Deleting::SoftDeleted]).to_a
          expect(soft_deleted_events.count).to eq(1)
          expect(soft_deleted_events.first.data).to eq(
            {
              business_reference: business_reference,
              reason: Types::DeletionReason['retention_rule'],
              deleted_by: 'system_automated'
            }
          )
        end

        it 'publishes a soft deleted sns event for the application' do
          expect(soft_deleted_event).to have_received(:publish)
        end

        it 'extends the `review_deletion_at` timestamp by the soft deletion period' do
          expect(deletable_entity.reload.review_deletion_at).to eq(current_date + Deleting::SOFT_DELETION_PERIOD)
        end

        it 'sets `soft_deleted_at` on the application' do
          expect(crime_application.reload.soft_deleted_at).to be_within(2.seconds).of(Time.zone.now)
        end

        context 'when soft deletion period has passed' do
          before do
            travel_to current_date + Deleting::SOFT_DELETION_PERIOD
            automate_deletion.call
          end

          it 'does not call MAAT again after the soft deletion period has expired' do
            expect(maat_get_record).to have_received(:by_maat_id!).once
          end

          it 'does not publish another SoftDeleted event' do
            expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(1)
          end

          it 'publishes a HardDeleted event' do
            hard_deleted_events = events_in_stream.of_type([Deleting::HardDeleted]).to_a
            expect(hard_deleted_events.count).to eq(1)
            expect(hard_deleted_events.first.data).to eq(
              {
                business_reference: business_reference,
                reason: Types::DeletionReason['retention_rule'],
                deleted_by: 'system_automated'
              }
            )
          end

          it 'deletion of documents occurs' do
            expect(hard_delete_documents).to have_received(:call).with(
              events_in_stream.of_type([Deleting::HardDeleted]).first
            )
          end

          it 'deletion of submitted applications occurs' do
            expect(hard_delete_submitted_applications).to have_received(:call).with(
              events_in_stream.of_type([Deleting::HardDeleted]).first
            )
          end

          it 'removes deletable_entities record' do
            expect(DeletableEntity.find_by(business_reference:)).to be_nil
          end
        end
      end

      context 'with a granted decision in MAAT' do
        let(:maat_record) do
          MAAT::Record.new(
            maat_ref: maat_id,
            usn: business_reference,
            ioj_result: 'PASS',
            ioj_assessor_name: 'Jo Bloggs',
            app_created_date: Time.zone.local(2022, 9, 4).as_json,
            means_result: 'PASS',
            means_assessor_name: 'Jo Bloggs',
            date_means_created: Time.zone.local(2022, 9, 10).as_json,
            funding_decision: 'GRANTED'
          )
        end

        it 'calls MAAT' do
          expect(maat_get_record).to have_received(:by_maat_id!).with(maat_id).once
        end

        it 'publishes a MaatRecordUpdated event' do
          maat_record_updated_events = events_in_stream.of_type([Deciding::MaatRecordUpdated])
          expect(maat_record_updated_events.count).to eq(1)
          expect(maat_record_updated_events.first.data).to eq(
            {
              business_reference: business_reference,
              maat_record: maat_record.as_json
            }
          )
        end

        it 'publishes a DecisionUpdated event' do
          decision_updated_events = events_in_stream.of_type([Deciding::DecisionUpdated])
          expect(decision_updated_events.count).to eq(1)
          expect(decision_updated_events.first.data).to eq(
            {
              business_reference: business_reference,
              decision_id: maat_id,
              overall_decision: 'granted'
            }
          )
        end

        it 'does not publish a SoftDeleted event' do
          expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(0)
        end

        it 'does not publish a soft deleted sns event for the application' do
          expect(soft_deleted_event).not_to have_received(:publish)
        end

        it 'extends the `review_deletion_at` timestamp by 7 years from the date means created' do
          expect(deletable_entity.reload.review_deletion_at).to eq(Time.zone.local(2022, 9, 10) + 7.years)
        end

        it 'does not set `soft_deleted_at` on the application' do
          expect(crime_application.reload.soft_deleted_at).to be_nil
        end
      end
    end

    context 'when completed 3 years ago without a maat_id' do
      let(:maat_id) { nil }
      let(:returned_maat_ref) { 9_874_622 }

      let(:events) do
        [
          Deleting::ApplicationMigrated, Time.zone.local(2022, 9, 4),
          {
            entity_id: entity_id,
            entity_type: entity_type,
            business_reference: business_reference,
            maat_id: maat_id,
            decision_id: nil,
            overall_decision: nil,
            submitted_at: Time.zone.local(2022, 9, 1),
            returned_at: nil,
            reviewed_at: Time.zone.local(2022, 9, 4),
            last_updated_at: Time.zone.local(2022, 9, 4),
            review_status: 'assessment_completed'
          }
        ]
      end

      let!(:deletable_entity) do
        DeletableEntity.create!(business_reference: business_reference,
                                review_deletion_at: Time.zone.local(2022, 9, 4))
      end

      let(:maat_record) do
        MAAT::Record.new(
          maat_ref: returned_maat_ref,
          usn: business_reference,
          ioj_result: 'PASS',
          ioj_assessor_name: 'Jo Bloggs',
          app_created_date: Time.zone.local(2022, 9, 4).as_json,
          means_result: 'FAIL',
          means_assessor_name: 'Jo Bloggs',
          date_means_created: Time.zone.local(2022, 9, 5).as_json,
          funding_decision: 'FAILMEANS'
        )
      end

      before do
        allow(Events::SoftDeleted).to receive(:new)
          .with(reference: crime_application.reference, soft_deleted_at: current_date)
          .and_return(soft_deleted_event)
        allow(Deleting::Handlers::HardDeleteDocuments).to receive(:new) {
          hard_delete_submitted_applications
        }
        allow(Deleting::Handlers::HardDeleteSubmittedApplications).to receive(:new) {
          hard_delete_documents
        }
        allow(hard_delete_documents).to receive(:call)
        allow(hard_delete_submitted_applications).to receive(:call)
        allow(MAAT::GetRecord).to receive(:new).and_return(maat_get_record)
        allow(maat_get_record).to receive(:by_usn!).with(business_reference.to_s).and_return(maat_record)
        allow(maat_get_record).to receive(:by_maat_id!)

        publish_events
        automate_deletion.call
      end

      it_behaves_like 'an application with events'

      it 'fetches the MAAT record by USN' do
        expect(maat_get_record).to have_received(:by_usn!).with(business_reference.to_s).once
      end

      it 'does not call MAAT by maat_id' do
        expect(maat_get_record).not_to have_received(:by_maat_id!)
      end

      it 'publishes a DecisionUpdated event using the returned maat_ref as decision_id' do
        decision_updated_events = events_in_stream.of_type([Deciding::DecisionUpdated])
        expect(decision_updated_events.count).to eq(1)
        expect(decision_updated_events.first.data).to eq(
          {
            business_reference: business_reference,
            decision_id: returned_maat_ref,
            overall_decision: 'refused_failed_means'
          }
        )
      end

      it 'publishes a SoftDeleted event' do
        expect(events_in_stream.of_type([Deleting::SoftDeleted]).count).to eq(1)
      end

      it 'extends the `review_deletion_at` timestamp by the soft deletion period' do
        expect(deletable_entity.reload.review_deletion_at).to eq(current_date + Deleting::SOFT_DELETION_PERIOD)
      end

      it 'sets `soft_deleted_at` on the application' do
        expect(crime_application.reload.soft_deleted_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
