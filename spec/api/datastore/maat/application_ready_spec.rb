require 'rails_helper'

RSpec.describe 'get application ready for maat' do
  describe 'GET /api/maat/applications/:usn' do
    let(:api_request) { get "/api/maat/applications/#{application_usn}" }

    let(:application) do
      CrimeApplication.new(
        application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
        review_status: :ready_for_assessment,
      )
    end

    let(:application_usn) { application.application['reference'] }

    context 'with a ready for assessment application' do
      before do
        allow(CrimeApplication).to receive(:find_by)
          .with(reference: application_usn, review_status: :ready_for_assessment)
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

    context 'with a completed application' do
      before do
        application.update!(review_status: :assessment_completed, reviewed_at: 1.week.ago)
        api_request
      end

      it_behaves_like 'an error that raises a 404 status code'
    end

    context 'with a returned application' do
      before do
        application.update!(review_status: :returned_to_provider, reviewed_at: 1.week.ago,
                            returned_at: 1.week.ago)
        api_request
      end

      it_behaves_like 'an error that raises a 404 status code'
    end

    context 'with a received application' do
      before do
        application.update!(review_status: :application_received)
        api_request
      end

      it_behaves_like 'an error that raises a 404 status code'
    end

    context 'when not found' do
      before do
        allow(CrimeApplication).to receive(:find_by)
          .with(reference: application_usn, review_status: :ready_for_assessment) {
            raise ActiveRecord::RecordNotFound
          }

        api_request
      end

      it_behaves_like 'an error that raises a 404 status code'
    end
  end
end
