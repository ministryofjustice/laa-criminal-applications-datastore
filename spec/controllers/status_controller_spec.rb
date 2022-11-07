require 'rails_helper'

RSpec.describe StatusController do
  describe '#ping' do
    it 'has a 200 response code' do
      get :ping, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns the expected payload' do
      get :ping, format: :json
      expect(
        JSON.parse(response.body).keys
      ).to eq(%w[build_date build_tag commit_id])
    end
  end
end
