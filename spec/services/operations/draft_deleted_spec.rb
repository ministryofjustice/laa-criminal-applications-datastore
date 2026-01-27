require 'rails_helper'

describe Operations::DraftDeleted do
  subject { described_class.new(entity_id:, entity_type:, business_reference:, reason:, deleted_by:) }

  let(:entity_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:entity_type) { Types::ApplicationType['initial'] }
  let(:business_reference) { '7000001' }
  let(:reason) { Types::DeletionReason['retention_rule'] }
  let(:deleted_by) { '1' }
  let(:deleting_stream) { Rails.configuration.event_store.read.stream("Deleting$#{business_reference}") }
  let(:event) { Rails.configuration.event_store.read.stream("Deleting$#{business_reference}").first }

  describe '#call' do
    it 'publishes a DraftDeleted event with the expected attributes' do
      expect(deleting_stream.map(&:event_type)).to match []
      subject.call
      expect(event.data).to eq(
        {
          entity_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
          entity_type: 'initial',
          business_reference: '7000001',
          reason: 'retention_rule',
          deleted_by: '1',
          deleted_from: 'crime_apply'
        }
      )
      expect(deleting_stream.map(&:event_type)).to match ['Applying::DraftDeleted']
    end
  end
end
