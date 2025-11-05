require 'rails_helper'

RSpec.describe Deleting::Commands::Exempt do
  subject(:exempt) { described_class }

  include_context 'with published events'

  let(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end
  let(:entity_id) { crime_application.id }
  let(:business_reference) { crime_application.reference }
  let(:entity_type) { crime_application.application_type }
  let(:event_stream) { "Deleting$#{business_reference}" }
  let(:current_date) { Time.zone.local(2025, 9, 6) }

  let(:events) do
    [
      Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
      Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id:, entity_type:, business_reference: },
      Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: entity_id, entity_type: entity_type,
                                                          business_reference: business_reference,
                                                          reason: 'duplicate_application' }
    ]
  end
  let(:reason) { Types::DeletionExemptionReason['deleted_in_error'] }
  let(:exempt_until) { Time.zone.local(2025, 9, 23) }

  before do
    travel_to current_date
    publish_events
  end

  context 'when applying an exemption to a soft deleted application' do
    before do
      event_store.with_metadata(timestamp: Time.zone.local(2025, 9, 4)) do
        event_store.publish(Deleting::SoftDeleted.new(data:
        {
          entity_id: entity_id, entity_type: entity_type,
          business_reference: business_reference,
          reason: Types::DeletionReason['retention_rule'],
          deleted_by: 'system_automated'
        }), stream_name: event_stream)
      end
      exempt.new(business_reference:, reason:, exempt_until:).call
    end

    it 'creates an ExemptFromDeletion event' do
      event = events_in_stream.to_a.find { |e| e.event_type == 'Deleting::ExemptFromDeletion' }
      expect(event.data).to eq(
        {
          business_reference:,
          entity_id:,
          entity_type:,
          exempt_until:,
          reason:
        }
      )
    end

    it 'clears the soft_deleted_at timestamp' do
      expect(crime_application.reload.soft_deleted_at).to be_nil
    end

    it 'sets `review_deletion_at` to the given date' do
      expect(DeletableEntity.find_by(business_reference:).review_deletion_at).to eq(exempt_until)
    end

    context 'when `exempt_until` is not provided' do
      let(:exempt_until) { nil }

      it 'extends `review_deletion_at` by the retention period' do
        expect(DeletableEntity.find_by(business_reference:).review_deletion_at).to eq(current_date + 2.years)
      end
    end
  end

  context 'when applying an exemption to a hard deleted application' do
    before do
      event_store.with_metadata(timestamp: Time.zone.local(2025, 9, 4)) do
        event_store.publish(Deleting::SoftDeleted.new(data:
        {
          entity_id: entity_id, entity_type: entity_type,
          business_reference: business_reference,
          reason: Types::DeletionReason['retention_rule'],
          deleted_by: 'system_automated'
        }), stream_name: event_stream)
      end
      event_store.with_metadata(timestamp: Time.zone.local(2025, 9, 18)) do
        event_store.publish(Deleting::HardDeleted.new(data:
        {
          entity_id: entity_id, entity_type: entity_type,
          business_reference: business_reference,
          deletion_entry_id: DeletionEntry.create!(
            record_id: entity_id,
            record_type: Types::RecordType['application'],
            business_reference: business_reference,
            deleted_by: 'system_automated',
            reason: Types::DeletionReason['retention_rule']
          ).id
        }), stream_name: event_stream)
      end
    end

    it 'raises a CannotBeExempt exception' do
      expect do
        exempt.new(business_reference:, reason:, exempt_until:).call
      end.to raise_error Deleting::Deletable::CannotBeExempt
    end
  end
end
