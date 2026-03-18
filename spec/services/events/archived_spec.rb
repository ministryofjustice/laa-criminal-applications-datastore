require 'rails_helper'

describe Events::Archived do
  subject(:archived_event) { described_class.new(event_data) }

  let(:event_data) do
    {
      entity_id: 'f7b429cc',
      business_reference: 673_209,
      entity_type: 'initial',
      archived_at: DateTime.parse('2024-06-01')
    }
  end

  describe '#name' do
    it 'returns the correct event name' do
      expect(archived_event.name).to eq('Deleting::Archived')
    end
  end

  describe '#message' do
    it 'returns the correct message from event data' do
      expect(archived_event.message).to eq(
        id: 'f7b429cc',
        archived_at: DateTime.parse('2024-06-01'),
        application_type: 'initial',
        reference: 673_209
      )
    end
  end

  describe '#publish' do
    before do
      allow(Messaging::EventsPublisher).to receive(:publish)
    end

    it 'publishes itself via the EventsPublisher' do
      archived_event.publish

      expect(Messaging::EventsPublisher).to have_received(:publish).with(archived_event)
    end
  end
end
