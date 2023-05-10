require 'rails_helper'

RSpec.describe 'get application' do
  let(:application_id) { application.submitted_details['id'] }

  let(:application) do
    CrimeApplication.create(
      submitted_details: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe 'GET /api/applications/:application_id' do
    subject(:api_request) do
      get "/api/v1/applications/#{application_id}"
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-review] do
      before { api_request }
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

      it "returns the application's details" do
        expect(JSON.parse(response.body)['id']).to eq(application_id)
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

      it_behaves_like 'an error that raises a 404 status code'
    end
  end
end
