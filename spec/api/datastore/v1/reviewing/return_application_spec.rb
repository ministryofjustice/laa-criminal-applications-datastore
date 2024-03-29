require 'rails_helper'

RSpec.describe 'return application' do
  let(:application) do
    CrimeApplication.create!(
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
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
        "/api/v1/applications/#{application.id}/return",
        params: { return_details: }
      )
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-review] do
      before { api_request }
    end

    context 'with a submitted application' do
      it 'marks the application as returned' do
        expect { api_request }.to change { application.reload.status }
          .from('submitted').to('returned')
      end

      it 'records the return details' do
        expect { api_request }.to change { application.reload.return_details }.from(nil)
      end

      it 'records returned_at' do
        expect { api_request }.to change { application.reload.returned_at }
          .from(nil)
      end

      describe 'returned application' do
        subject(:returned_application) { JSON.parse(response.body) }

        before { api_request }

        describe 'status' do
          subject(:status) { returned_application['status'] }

          it { is_expected.to eq Types::ApplicationStatus['returned'] }
        end

        describe 'return_details' do
          subject(:details) { returned_application['return_details'] }

          it 'include the reason' do
            expect(details['reason']).to eq return_details.fetch(:reason)
          end

          it 'include the details' do
            expect(details['details']).to eq return_details.fetch(:details)
          end
        end
      end
    end

    context 'with a returned application' do
      before do
        application.update!(status: :returned, returned_at: 1.week.ago)
      end

      it 'does not record the return details' do
        expect { api_request }.not_to change { application.reload.return_details }.from(nil)
        expect(response).to have_http_status :conflict
      end
    end

    context 'with a completed application' do
      before do
        application.update!(review_status: :assessment_completed, reviewed_at: 1.week.ago)
      end

      it_behaves_like 'an error that raises a 409 status code'
    end

    context 'with an unknown application' do
      subject(:api_request) do
        put(
          "/api/v1/applications/#{SecureRandom.uuid}/return",
          params: { return_details: }
        )
      end

      it 'does not record the return details' do
        expect { api_request }.not_to change { application.reload.return_details }.from(nil)
        expect(response).to have_http_status :not_found
      end
    end
  end
end
