require 'rails_helper'

RSpec.describe 'complete application' do
  let(:application) do
    CrimeApplication.create!(
      application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe 'PUT /api/applications/application_id/complete' do
    subject(:api_request) do
      put(
        "/api/v2/applications/#{application.id}/complete"
      )
    end

    context 'with a submitted application' do
      it 'marks the application as complete' do
        expect { api_request }.to change { application.reload.review_status }
          .from('application_received').to('assessment_completed')
      end

      it 'records reviewed_at' do
        expect { api_request }.to change { application.reload.reviewed_at }
          .from(nil)
      end
    end

    context 'with a completed application' do
      before do
        application.update!(review_status: :assessment_completed, reviewed_at: 1.week.ago)
      end

      it 'raises a 409 error' do
        api_request
        expect(response).to have_http_status :conflict
      end
    end

    context 'with a returned application' do
      before do
        application.update!(status: :returned, reviewed_at: 1.week.ago)
      end

      it 'raises a 409 error' do
        api_request
        expect(response).to have_http_status :conflict
      end
    end

    context 'with an unknown application' do
      subject(:api_request) do
        put(
          "/api/v2/applications/#{SecureRandom.uuid}/complete"
        )
      end

      it 'responds with not found http status' do
        api_request
        expect(response).to have_http_status :not_found
      end
    end
  end
end
