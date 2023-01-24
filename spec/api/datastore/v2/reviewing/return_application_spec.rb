require 'rails_helper'

RSpec.describe 'create application' do
  let(:application) do
    CrimeApplication.create!(
      application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:return_details) do
    {
      reason: Types::RETURN_REASONS.sample,
      details: 'Detailed reason why the application is being returned'
    }
  end

  describe 'PUT /api/applications/application_id/return' do
    subject(:api_request) do
      put(
        "/api/v2/applications/#{application.id}/return",
        params: { return_details: }
      )
    end

    context 'with a submitted application' do
      it 'marks the application as returned' do
        expect { api_request }.to change { application.reload.status }
          .from('submitted').to('returned')
      end

      it 'records the return details' do
        expect { api_request }.to change(ReturnDetails, :count).from(0).to(1)
      end

      it 'records returned_at' do
        expect { api_request }.to change { application.reload.returned_at }
          .from(nil)
      end
    end

    context 'with a returned application' do
      before do
        application.update!(returned_at: 1.week.ago)
      end

      it 'does not record the return details' do
        expect { api_request }.not_to change(ReturnDetails, :count)
        expect(response).to have_http_status :conflict
      end
    end

    context 'with an unkown application' do
      subject(:api_request) do
        put(
          "/api/v2/applications/#{SecureRandom.uuid}/return",
          params: { return_details: }
        )
      end

      it 'does not record the return details' do
        expect { api_request }.not_to change(ReturnDetails, :count)
        expect(response).to have_http_status :not_found
      end
    end
  end
end
