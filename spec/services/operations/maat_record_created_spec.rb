require 'rails_helper'

describe Operations::MAATRecordCreated do
  subject { described_class.new(entity_id:, entity_type:, business_reference:, maat_id:) }

  let(:entity_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:entity_type) { Types::ApplicationType['initial'] }
  let(:business_reference) { '7000001' }
  let(:maat_id) { '987654321' }
  let(:deleting_stream) { Rails.configuration.event_store.read.stream("Deleting$#{business_reference}") }
  let(:event) { Rails.configuration.event_store.read.stream("Deleting$#{business_reference}").first }

  describe '#call' do
    it 'publishes a MaatRecordCreated event with the expected attributes' do
      expect(deleting_stream.map(&:event_type)).to match []
      subject.call
      expect(deleting_stream.map(&:event_type)).to match ['Deciding::MaatRecordCreated']
      expect(event.data).to eq({ entity_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a', entity_type: 'initial',
                                 business_reference: '7000001', maat_id: '987654321' })
    end
  end
end
