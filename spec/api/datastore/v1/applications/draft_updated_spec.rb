require 'rails_helper'

RSpec.describe 'create a DraftUpdated event' do
  let(:operation_class) { Operations::DraftUpdated }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:entity_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:entity_type) { 'initial' }
  let(:business_reference) { '7000001' }

  before do
    allow(
      operation_class
    ).to receive(:new).with(entity_id:, entity_type:, business_reference:).and_return(stubbed_operation)
  end

  describe 'POST /api/v1/applications/draft_updated' do
    subject(:api_request) do
      post '/api/v1/applications/draft_updated', params: { entity_id:, entity_type:, business_reference: }
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-apply-preprod] do
      before { api_request }
    end
  end
end
