require 'rails_helper'

RSpec.describe Datastore::V2::Applications do
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

  describe 'POST /api/applications' do
    subject(:api_request) do
      post '/api/v2/applications', params: { application: payload }
    end

    let(:record) { instance_double(CrimeApplication, id: application_id) }
    let(:payload) { LaaCrimeSchemas.fixture(1.0).read }

    context 'with a valid request' do
      before do
        allow(CrimeApplication).to receive(:create!).with(
          application: JSON.parse(payload)
        ).and_return(record)

        api_request
      end

      it 'stores the application in the datastore' do
        expect(CrimeApplication).to have_received(:create!).with(
          application: JSON.parse(payload)
        )
      end

      it 'returns http status 201' do
        expect(response).to have_http_status(:created)
      end

      it 'includes the record id in the response body' do
        expect(JSON.parse(response.body)).to match({ 'id' => application_id })
      end
    end

    context 'when the application already exists' do
      before do
        allow(CrimeApplication).to receive(:create!).with(
          application: JSON.parse(payload)
        ) { raise ActiveRecord::RecordNotUnique }

        api_request
      end

      it 'returns 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error informatation' do
        expect(response.body).to include('Record not unique')
      end
    end

    context 'with a schema error' do
      before do
        allow(CrimeApplication).to receive(:create!).with(
          application: JSON.parse(payload)
        ).and_return(record)

        api_request
      end

      let(:payload) do
        LaaCrimeSchemas.fixture(1.0, name: :application_invalid).read
      end

      it 'does not store the application' do
        expect(CrimeApplication).not_to have_received(:create!)
      end

      it 'returns 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error informatation' do
        expect(response.body).to include('failed_attribute')
      end
    end
  end
end
