require 'rails_helper'

RSpec.describe 'list documents by USN' do
  let(:operation_class) { Operations::Documents::List }
  let(:stubbed_operation) { instance_double(operation_class, call: {}) }

  let(:usn) { 123 }

  before do
    allow(
      operation_class
    ).to receive(:new).with(usn:).and_return(stubbed_operation)
  end

  describe 'GET /documents/:usn' do
    subject(:api_request) do
      get "/api/v1/documents/#{usn}"
    end

    it_behaves_like 'a documents API endpoint'

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-review] do
      before { api_request }
    end
  end
end
