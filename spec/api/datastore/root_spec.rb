require 'rails_helper'

RSpec.describe 'Root' do
  describe 'handle unknown routes' do
    subject(:api_request) { get '/api/v1/foobar' }

    before do
      api_request
    end

    it_behaves_like 'an authorisable endpoint', %w[*]

    it 'returns http status 404' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns the error details' do
      expect(
        JSON.parse(response.body)
      ).to eq({ 'error' => 'Not found', 'status' => 404 })
    end
  end
end
