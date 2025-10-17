require 'rails_helper'

RSpec.describe 'create a DraftCreated event' do
  let(:operation_class) { Operations::DraftCreated }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:entity_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:entity_type) { 'initial' }
  let(:business_reference) { '7000001' }
  let(:created_at) { nil }

  before do
    allow(
      operation_class
    ).to receive(:new).with(entity_id:, entity_type:, business_reference:, created_at:).and_return(stubbed_operation)
  end

  describe 'POST /api/v1/applications/draft_created' do
    subject(:api_request) do
      post '/api/v1/applications/draft_created', params: { entity_id:, entity_type:, business_reference:, created_at: }
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-apply-preprod] do
      before { api_request }
    end
  end
end
