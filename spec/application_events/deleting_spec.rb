require 'rails_helper'

RSpec.describe Deleting do
  subject(:deletable) do
    repository = AggregateRoot::Repository.new(event_store)
    repository.load(Deleting::Deletable.new, described_class.stream_name(business_reference))
  end

  let(:event_store) { Rails.configuration.event_store }
  let(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end
  let(:entity_id) { crime_application.id }
  let(:business_reference) { crime_application.reference }
  let(:entity_type) { crime_application.application_type }
  let(:maat_id) { '987654321' }

  let(:events_in_stream) do
    event_store.read.stream("Deleting$#{business_reference}").map(&:event_type)
  end

  before do
    travel_to Time.zone.local(2025, 9, 6)
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

      before do
        events.each_slice(3) do |slice|
          event_class = slice[0]
          timestamp = slice[1]
          data = slice[2]
          event_store.with_metadata(timestamp:) do
            event_store.publish(event_class.new(data:))
          end
        end
      end

      it 'has all the relevant events' do
        expect(events_in_stream).to eq(
          [
            'Applying::DraftCreated',
            'Applying::DraftUpdated',
            'Applying::DraftUpdated',
            'Applying::DraftUpdated',
            'Applying::DraftDeleted',
            'Applying::Submitted',
            'Reviewing::SentBack'
          ]
        )
      end

      it 'is eligible for deletion' do
        expect(deletable.soft_deletable?).to be(true)
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

      before do
        events.each_slice(3) do |slice|
          event_class = slice[0]
          timestamp = slice[1]
          data = slice[2]
          event_store.with_metadata(timestamp:) do
            event_store.publish(event_class.new(data:))
          end
        end
      end

      it 'has all the relevant events' do
        expect(events_in_stream).to eq(
          [
            'Applying::DraftCreated',
            'Applying::DraftUpdated',
            'Applying::DraftUpdated',
            'Applying::DraftUpdated',
            'Applying::DraftDeleted',
            'Applying::Submitted',
            'Deciding::MaatRecordCreated',
            'Reviewing::SentBack'
          ]
        )
      end

      it 'is not eligible for deletion' do
        expect(deletable.soft_deletable?).to be(false)
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

      before do
        events.each_slice(3) do |slice|
          event_class = slice[0]
          timestamp = slice[1]
          data = slice[2]
          event_store.with_metadata(timestamp:) do
            event_store.publish(event_class.new(data:))
          end
        end
      end

      it 'has all the relevant events' do
        expect(events_in_stream).to eq(
          [
            'Applying::DraftCreated',
            'Applying::DraftUpdated',
            'Applying::DraftUpdated',
            'Applying::DraftUpdated',
            'Applying::DraftDeleted',
            'Applying::Submitted',
            'Reviewing::SentBack',
            'Applying::DraftCreated'
          ]
        )
      end

      it 'is not eligible for deletion' do
        expect(deletable.soft_deletable?).to be(false)
      end
    end
  end
end
