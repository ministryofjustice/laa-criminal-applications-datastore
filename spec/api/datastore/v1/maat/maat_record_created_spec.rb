require 'rails_helper'

RSpec.describe 'create a MaatRecordCreated event' do
  let(:operation_class) { Operations::MAATRecordCreated }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:entity_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:entity_type) { 'initial' }
  let(:business_reference) { '7000001' }
  let(:maat_id) { '987654321' }

  before do
    allow(
      operation_class
    ).to receive(:new).with(entity_id:, entity_type:, business_reference:, maat_id:).and_return(stubbed_operation)
  end

  describe 'POST /api/v1/maat/applications/maat_record_created' do
    subject(:api_request) do
      post '/api/v1/maat/applications/maat_record_created',
           params: { entity_id:, entity_type:, business_reference:, maat_id: }
    end

    it_behaves_like 'an authorisable endpoint', %w[maat-adapter maat-adapter-dev maat-adapter-uat] do
      before { api_request }
    end
  end
end
