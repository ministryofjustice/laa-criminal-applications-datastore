require 'rails_helper'

RSpec.describe 'health check' do
  context 'when database is okay' do
    it 'returns status ok' do
      get '/api/v2/health'
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
      get '/api/v2/health'
      expect(response).to have_http_status :service_unavailable
    end
  end
end
