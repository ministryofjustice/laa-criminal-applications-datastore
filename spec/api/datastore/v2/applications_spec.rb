require 'rails_helper'

RSpec.describe Datastore::V2::Applications do
  describe 'POST /api/applications' do
    subject(:api_request) do
      post '/api/v2/applications', params: { application: payload }
    end

    let(:record) { instance_double(CrimeApplication, id: '1234567') }
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

      it 'includes the record id and status in the response body' do
        expect(response.body).to match({
          id: '1234567',
          status: 'created'
        }.to_json)
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
