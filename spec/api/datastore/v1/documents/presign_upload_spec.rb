require 'rails_helper'

RSpec.describe 'presign a document upload' do
  let(:operation_class) { Operations::Documents::PresignUrl }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:object_key) { '123/xyz/foobar' }
  let(:s3_opts) { {} }

  before do
    allow(
      operation_class
    ).to receive(:new).with(:put, object_key:, s3_opts:).and_return(stubbed_operation)
  end

  describe 'PUT /documents/presign_upload' do
    subject(:api_request) do
      put '/api/v1/documents/presign_upload', params: { object_key:, s3_opts: }
    end

    it_behaves_like 'a documents API endpoint'

    it_behaves_like 'an authorisable endpoint', %w[crime-apply] do
      before { api_request }
    end
  end
end
