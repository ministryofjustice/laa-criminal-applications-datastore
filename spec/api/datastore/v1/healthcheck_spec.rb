require 'rails_helper'

describe 'Healthcheck' do
  describe 'GET /health' do
    subject(:api_request) { get '/api/v1/health' }

    it_behaves_like 'an authorisable endpoint', %w[*] do
      before { api_request }
    end

    context 'when service is healthy' do
      before do
        api_request
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)

        expect(
          response.parsed_body
        ).to eq('status' => 'ok', 'error' => nil)
      end
    end

    context 'when service is unhealthy' do
      before do
        allow(ActiveRecord::Base).to receive(:connection) {
          raise StandardError
        }

        api_request
      end

      it 'returns service unavailable' do
        expect(response).to have_http_status(:service_unavailable)

        expect(
          response.parsed_body
        ).to eq('status' => 'service_unavailable', 'error' => 'Database Connection Error')
      end
    end
  end
end
