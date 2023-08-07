require 'rails_helper'

RSpec.describe 'delete a document' do
  let(:operation_class) { Operations::Documents::Delete }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:object_key) { 'MTIzL3h5ei9mb29iYXI=' }

  before do
    allow(
      operation_class
    ).to receive(:new).with(object_key:).and_return(stubbed_operation)
  end

  describe 'DELETE /documents/:object_key' do
    subject(:api_request) do
      delete "/api/v1/documents/#{object_key}"
    end

    it_behaves_like 'a documents API endpoint'

    it_behaves_like 'an authorisable endpoint', %w[crime-apply] do
      before { api_request }
    end
  end
end
