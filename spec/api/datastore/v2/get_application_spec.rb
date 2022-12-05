require 'rails_helper'

RSpec.describe 'get application' do
  let(:application_id) { application.application['id'] }

  let(:application) do
    instance_double(
      CrimeApplication,
      application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe 'GET /api/applications/:id' do
    subject(:api_request) do
      get "/api/v2/applications/#{application_id}"
    end

    context 'when found' do
      before do
        allow(CrimeApplication).to receive(:find)
          .with(application_id)
          .and_return(application)

        api_request
      end

      it 'returns http status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the application details' do
        expect(JSON.parse(response.body)).to match(application.application)
      end

      it 'returned details satisfy with schema' do
        expect(
          LaaCrimeSchemas::Validator.new(response.body, version: 1.0)
        ).to be_valid
      end
    end

    context 'when not found' do
      before do
        allow(CrimeApplication).to receive(:find) {
          raise ActiveRecord::RecordNotFound
        }

        api_request
      end

      it 'returns http status Not Found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
