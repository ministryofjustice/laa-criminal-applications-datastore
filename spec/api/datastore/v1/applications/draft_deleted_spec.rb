require 'rails_helper'

RSpec.describe 'create a DraftDeleted event' do
  let(:operation_class) { Operations::DraftDeleted }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:entity_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:entity_type) { 'initial' }
  let(:business_reference) { '7000001' }
  let(:reason) { 'retention_rule' }
  let(:deleted_by) { '1' }

  before do
    allow(
      operation_class
    ).to receive(:new).with(entity_id:, entity_type:, business_reference:, reason:,
                            deleted_by:).and_return(stubbed_operation)
  end

  describe 'POST /api/v1/applications/draft_deleted' do
    subject(:api_request) do
      post '/api/v1/applications/draft_deleted', params: { entity_id:, entity_type:, business_reference:, reason:,
                                                           deleted_by: }
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-apply-preprod] do
      before { api_request }
    end
  end
end
