require 'rails_helper'

RSpec.describe 'health check' do
  context 'when databases are okay' do
    before do
      allow(Dynamoid::Tasks::Database).to receive(:ping).and_return(true)
    end

    it 'returns status ok' do
      get '/api/v1/health'
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
      get '/api/v1/health'
      expect(response).to have_http_status :service_unavailable
    end
  end

  context 'when dynamo is down' do
    before do
      allow(Dynamoid::Tasks::Database).to receive(:ping) {
        raise StandardError
      }
    end

    it 'returns service unavailable' do
      get '/api/v1/health'
      expect(response).to have_http_status :service_unavailable
    end
  end
end
