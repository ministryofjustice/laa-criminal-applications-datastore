require 'rails_helper'

RSpec.describe 'Archive application' do
  let(:application) do
    CrimeApplication.create!(
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe 'PUT /api/applications/application_id/archive' do
    subject(:api_request) do
      put(
        "/api/v1/applications/#{application.id}/archive"
      )
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-apply] do
      before { api_request }
    end

    context 'with a returned application' do
      before do
        application.update!(status: :returned, returned_at: 1.week.ago)
      end

      it 'persists archived and archived_at timestamp' do
        expect { api_request }.to change { application.reload.archived_at }
          .from(nil)
      end
    end

    context 'with an archived application' do
      before do
        application.update!(archived_at: Time.zone.now)
      end

      it_behaves_like 'an error that raises a 409 status code'
    end

    context 'with a submitted application' do
      before do
        application.update!(status: :submitted)
      end

      it_behaves_like 'an error that raises a 409 status code'
    end

    context 'with an unknown application' do
      subject(:api_request) do
        put(
          "/api/v1/applications/#{SecureRandom.uuid}/archive"
        )
      end

      it 'responds with not found http status' do
        api_request
        expect(response).to have_http_status :not_found
      end
    end
  end
end
