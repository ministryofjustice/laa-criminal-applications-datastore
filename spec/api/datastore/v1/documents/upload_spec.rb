require 'rails_helper'

RSpec.describe 'upload a document' do
  let(:operation_class) { Operations::Documents::Upload }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:usn) { 123 }
  let(:file) { nil } # not testing here the file object
  let(:payload) { { 'filename' => 'filename' } }

  before do
    allow(
      operation_class
    ).to receive(:new).with(usn:, file:, payload:).and_return(stubbed_operation)
  end

  describe 'POST /documents/:usn' do
    subject(:api_request) do
      post "/api/v1/documents/#{usn}", params: { file:, payload: }
    end

    it_behaves_like 'a documents API endpoint'

    it_behaves_like 'an authorisable endpoint', %w[crime-apply] do
      before { api_request }
    end
  end
end
