require 'rails_helper'

RSpec.describe Deleting::Handlers::HardDeleteDocuments do
  describe '#call' do
    let(:handler) { described_class.new }
    let(:business_reference) { 60_012 }
    let(:deleted_by) { 'system_automated' }
    let(:reason) { 'retention_rule' }
    let(:correlation_id) { SecureRandom.uuid }

    let(:event) do
      Deleting::HardDeleted.new(
        data: { business_reference:, reason:, deleted_by: },
        metadata: { correlation_id: }
      )
    end

    let(:documents) do
      [
        { object_key: 'doc_1', size: 123_123, last_modified: 2.years.ago.to_i },
        { object_key: 'doc_2', size: 223_223, last_modified: 2.years.ago.to_i }
      ]
    end

    before do
      allow(Operations::Documents::List)
        .to receive(:new)
        .with(usn: business_reference)
        .and_return(instance_double(Operations::Documents::List, call: documents))

      allow(Operations::Documents::Delete)
        .to receive(:new)
        .and_return(instance_double(Operations::Documents::Delete, call: true))

      allow(DeletionEntry).to receive(:create!)
    end

    it 'considers all documents for the given business reference' do
      handler.call(event)
      expect(Operations::Documents::List)
        .to have_received(:new).with(usn: business_reference)
    end

    it 'deletes each document returned by the list operation' do
      handler.call(event)
      documents.each do |doc|
        expect(Operations::Documents::Delete)
          .to have_received(:new).with(**doc.slice(:object_key))
      end
    end

    it 'persists a deletion entry for each deleted document' do
      allow(DeletionEntry).to receive(:create!).and_call_original
      expect { handler.call(event) }.to change {
        DeletionEntry.where(
          business_reference:, correlation_id:, deleted_by:, reason:,
        ).count
      }.from(0).to(2)
    end

    it 'correctly sets DeletionEntry attributes for each deleted document' do
      handler.call(event)

      documents.each do |doc|
        expect(DeletionEntry).to have_received(:create!).with(
          record_id: doc.fetch(:object_key),
          record_type: Types::RecordType['document'],
          business_reference: business_reference,
          deleted_by: deleted_by,
          deleted_from: Types::RecordSource['amazon_s3'],
          reason: reason,
          correlation_id: correlation_id
        )
      end
    end

    it 'raise an error if event is not HardDeleted' do
      expect { handler.call(Deleting::SoftDeleted.new) }.to raise_error Deleting::UnexpectedEventType
    end
  end
end
