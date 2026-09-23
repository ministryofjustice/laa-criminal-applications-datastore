require 'rails_helper'

RSpec.describe Deleting::Commands::SyncMAATRecord do
  subject(:sync_maat_record) { described_class.new(business_reference:) }

  include_context 'with published events'

  let(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end
  let(:entity_id) { crime_application.id }
  let(:business_reference) { crime_application.reference }
  let(:entity_type) { crime_application.application_type }
  let(:event_stream) { "Deleting$#{business_reference}" }
  let(:current_date) { Time.zone.local(2025, 9, 6) }
  let(:maat_get_record) { instance_double(MAAT::GetRecord) }

  let(:events) do
    [
      Deleting::ApplicationMigrated, Time.zone.local(2022, 9, 4),
      {
        entity_id: entity_id,
        entity_type: entity_type,
        business_reference: business_reference,
        maat_id: nil,
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

  before do
    travel_to current_date
    DeletableEntity.create!(business_reference: business_reference, review_deletion_at: Time.zone.local(2022, 9, 4))
    allow(MAAT::GetRecord).to receive(:new).and_return(maat_get_record)
    publish_events
  end

  context 'when MAAT raises RecordNotFound during a USN lookup' do
    let(:error) { MAAT::RecordNotFound.new }

    before do
      allow(maat_get_record).to receive(:by_usn!).and_raise(error)
      allow(Rails.error).to receive(:report)
    end

    it 'reports the error' do
      sync_maat_record.call
      expect(Rails.error).to have_received(:report).with(error)
    end

    it 'does not publish a MaatRecordUpdated event' do
      sync_maat_record.call
      expect(events_in_stream.of_type([Deciding::MaatRecordUpdated]).count).to eq(0)
    end

    it 'does not publish a DecisionUpdated event' do
      sync_maat_record.call
      expect(events_in_stream.of_type([Deciding::DecisionUpdated]).count).to eq(0)
    end
  end

  context 'when the application has maat_ids' do
    let(:events) do
      [
        Deleting::ApplicationMigrated, Time.zone.local(2022, 9, 4),
        {
          entity_id: entity_id,
          entity_type: entity_type,
          business_reference: business_reference,
          maat_id: 6_563_959,
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

    it 'calls the MAAT API with the numeric maat_id' do
      allow(maat_get_record).to receive(:by_maat_id!).and_raise(MAAT::RecordNotFound)
      allow(Rails.error).to receive(:report)

      sync_maat_record.call

      expect(maat_get_record).to have_received(:by_maat_id!).with(6_563_959)
    end
  end

  context 'when the application has decision_ids but no maat_ids' do
    let(:decision) do
      Decision.create!(crime_application: crime_application, maat_id: 7_654_321, funding_decision: 'refused')
    end

    let(:events) do
      [
        Applying::Submitted, Time.zone.local(2022, 9, 1),
        {
          entity_id:,
          entity_type:,
          business_reference:
        },
        Deciding::Decided, Time.zone.local(2022, 9, 4),
        {
          entity_id: entity_id,
          entity_type: entity_type,
          business_reference: business_reference,
          decision_id: decision.id,
          overall_decision: 'refused'
        },
        Reviewing::Completed, Time.zone.local(2022, 9, 4),
        {
          entity_id:,
          entity_type:,
          business_reference:
        }
      ]
    end

    it 'looks up the maat_id from the Decision record and calls the MAAT API' do
      allow(maat_get_record).to receive(:by_maat_id!).and_raise(MAAT::RecordNotFound)
      allow(Rails.error).to receive(:report)

      sync_maat_record.call

      expect(maat_get_record).to have_received(:by_maat_id!).with(7_654_321)
    end
  end

  context 'when the application has decision_ids but the Decision record does not exist' do
    let(:non_existent_decision_id) { SecureRandom.uuid }

    let(:events) do
      [
        Applying::Submitted, Time.zone.local(2022, 9, 1),
        {
          entity_id:,
          entity_type:,
          business_reference:
        },
        Deciding::Decided, Time.zone.local(2022, 9, 4),
        {
          entity_id: entity_id,
          entity_type: entity_type,
          business_reference: business_reference,
          decision_id: non_existent_decision_id,
          overall_decision: 'refused'
        },
        Reviewing::Completed, Time.zone.local(2022, 9, 4),
        {
          entity_id:,
          entity_type:,
          business_reference:
        }
      ]
    end

    it 'logs a warning and does not call the MAAT API' do
      allow(Rails.logger).to receive(:warn)
      allow(maat_get_record).to receive(:by_maat_id!)

      sync_maat_record.call

      expect(Rails.logger).to have_received(:warn).with(/Decision not found for id #{non_existent_decision_id}/)
      expect(maat_get_record).not_to have_received(:by_maat_id!)
    end
  end

  context 'when the application has decision_ids but the Decision has no maat_id' do
    let(:decision_without_maat_id) do
      Decision.create!(crime_application: crime_application, maat_id: nil, funding_decision: 'refused')
    end

    let(:events) do
      [
        Applying::Submitted, Time.zone.local(2022, 9, 1),
        {
          entity_id:,
          entity_type:,
          business_reference:
        },
        Deciding::Decided, Time.zone.local(2022, 9, 4),
        {
          entity_id: entity_id,
          entity_type: entity_type,
          business_reference: business_reference,
          decision_id: decision_without_maat_id.id,
          overall_decision: 'refused'
        },
        Reviewing::Completed, Time.zone.local(2022, 9, 4),
        {
          entity_id:,
          entity_type:,
          business_reference:
        }
      ]
    end

    it 'logs info and does not call the MAAT API' do
      allow(Rails.logger).to receive(:info)
      allow(maat_get_record).to receive(:by_maat_id!)

      sync_maat_record.call

      expect(Rails.logger).to have_received(:info).with(/has no maat_id, skipping/)
      expect(maat_get_record).not_to have_received(:by_maat_id!)
    end
  end

  context 'when the application has maat_ids and MAAT returns a granted decision with no dates' do
    let(:events) do
      [
        Deleting::ApplicationMigrated, Time.zone.local(2022, 9, 4),
        {
          entity_id: entity_id,
          entity_type: entity_type,
          business_reference: business_reference,
          maat_id: 6_563_959,
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

    # date_means_created and ioj_appeal_date are nil - an edge case that previously caused
    # latest_maat_timestamp to return nil and skip the application
    let(:maat_record) do
      MAAT::Record.new(
        maat_ref: 6_563_959,
        usn: business_reference,
        ioj_result: 'PASS',
        ioj_assessor_name: 'Jo Bloggs',
        passport_result: 'PASS',
        passport_assessor_name: 'Jo Bloggs',
        date_passport_created: Time.zone.local(2022, 9, 4).as_json,
        means_result: nil,
        date_means_created: nil,
        ioj_appeal_date: nil,
        app_created_date: Time.zone.local(2022, 9, 4).as_json,
        funding_decision: 'GRANTED'
      )
    end

    before do
      allow(maat_get_record).to receive(:by_maat_id!).with(6_563_959).and_return(maat_record)

      sync_maat_record.call
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

    it 'publishes a DecisionUpdated event using the maat_id as decision_id' do
      decision_updated_events = events_in_stream.of_type([Deciding::DecisionUpdated])
      expect(decision_updated_events.count).to eq(1)
      expect(decision_updated_events.first.data).to eq(
        {
          business_reference: business_reference,
          decision_id: 6_563_959,
          overall_decision: 'granted'
        }
      )
    end

    it 'sets deletion_at to last_significant_event_at plus the granted retention period' do
      Deleting::DeletableRepository.new.with_deletable(business_reference) do |deletable|
        expect(deletable.deletion_at).to eq(Time.zone.local(2022, 9, 4) + 7.years)
      end
    end
  end

  context 'when the application has maat_ids and MAAT returns dates that are \
    not newer than last_significant_event_at' do
    let(:events) do
      [
        Deleting::ApplicationMigrated, Time.zone.local(2022, 9, 4),
        {
          entity_id: entity_id,
          entity_type: entity_type,
          business_reference: business_reference,
          maat_id: 6_563_959,
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

    let(:maat_record) do
      MAAT::Record.new(
        maat_ref: 6_563_959,
        usn: business_reference,
        ioj_result: 'PASS',
        ioj_assessor_name: 'Jo Bloggs',
        means_result: nil,
        date_means_created: Time.zone.local(2022, 9, 4).as_json,
        app_created_ate: Time.zone.local(2022, 9, 4).as_json,
        funding_decision: 'GRANTED'
      )
    end

    before do
      allow(maat_get_record).to receive(:by_maat_id!).with(6_563_959).and_return(maat_record)

      sync_maat_record.call
    end

    it 'does not publish a MaatRecordUpdated event' do
      expect(events_in_stream.of_type([Deciding::MaatRecordUpdated]).count).to eq(0)
    end

    it 'does not publish a DecisionUpdated event' do
      expect(events_in_stream.of_type([Deciding::DecisionUpdated]).count).to eq(0)
    end
  end
end
