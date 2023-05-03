require 'rails_helper'

RSpec.describe 'ready for assessment application' do
  let(:application) do
    CrimeApplication.create!(
      application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe 'PUT /api/applications/application_id/mark_as_ready' do
    subject(:api_request) do
      put(
        "/api/v1/applications/#{application.id}/mark_as_ready"
      )
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-review] do
      before { api_request }
    end

    context 'with a submitted application' do
      it 'marks the application as ready for assessment' do
        expect { api_request }.to change { application.reload.review_status }
          .from('application_received').to('ready_for_assessment')
      end
    end

    context 'with a ready for assessment application' do
      before do
        application.update!(review_status: :ready_for_assessment)
      end

      it_behaves_like 'an error that raises a 409 status code'
    end

    context 'with a completed application' do
      before do
        application.update!(review_status: :assessment_completed, reviewed_at: 1.week.ago)
      end

      it_behaves_like 'an error that raises a 409 status code'
    end

    context 'with a returned application' do
      before do
        application.update!(status: :returned, reviewed_at: 1.week.ago)
      end

      it_behaves_like 'an error that raises a 409 status code'
    end

    context 'with an unknown application' do
      subject(:api_request) do
        put(
          "/api/v1/applications/#{SecureRandom.uuid}/mark_as_ready"
        )
      end

      it 'responds with not found http status' do
        api_request
        expect(response).to have_http_status :not_found
      end
    end
  end
end
