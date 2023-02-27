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

  describe '#health' do
    context 'when database is okay' do
      it 'returns status ok' do
        get :health, format: :json
        expect(response).to have_http_status :ok
      end
    end

    context 'when postgres is down' do
      before do
        allow(ActiveRecord::Base).to receive(:connection) {
          raise StandardError
        }
      end

      it 'returns service unavailable' do
        get :health, format: :json

        expect(response).to have_http_status :service_unavailable

        expect(
          JSON.parse(response.body)
        ).to eq('status' => 'service_unavailable', 'error' => 'Database Connection Error')
      end
    end
  end
end
