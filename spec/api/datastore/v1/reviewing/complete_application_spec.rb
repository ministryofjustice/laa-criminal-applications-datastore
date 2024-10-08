require 'rails_helper'

RSpec.describe 'complete application' do
  let(:application) do
    CrimeApplication.create!(
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe 'PUT /api/applications/application_id/complete' do
    subject(:api_request) do
      put(
        "/api/v1/applications/#{application.id}/complete"
      )
    end

    it_behaves_like 'an authorisable endpoint', %w[crime-review] do
      before { api_request }
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

    context 'with a submitted application that has decisions' do
      subject(:api_request) do
        put("/api/v1/applications/#{application.id}/complete", params: { decisions: })
      end

      let(:decisions) do
        [
          {
            'reference' => 1234,
            'maat_id' => nil,
            'interests_of_justice' => interests_of_justice,
            'means' => nil,
            'funding_decision' => 'granted',
            'comment' => 'test comment'
          }
        ].to_json
      end

      let(:interests_of_justice) do
        {
          'result' => 'pass',
          'details' => 'decision details',
          'assessed_by' => 'Grace Nolan',
          'assessed_on' => '2024-10-01 00:00:00'
        }
      end

      it 'marks the application as complete' do
        expect { api_request }.to change { application.reload.review_status }
          .from('application_received').to('assessment_completed')
      end

      it 'records reviewed_at' do
        expect { api_request }.to change { application.reload.reviewed_at }
          .from(nil)
      end

      it 'persists the decisions' do
        api_request
        decisions = application.reload.decisions
        expect(decisions.size).to eq(1)
        expect(decisions.first.interests_of_justice).to eq(interests_of_justice)
        expect(decisions.first.funding_decision).to eq('granted')
        expect(decisions.first.comment).to eq('test comment')
      end
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
          "/api/v1/applications/#{SecureRandom.uuid}/complete"
        )
      end

      it 'responds with not found http status' do
        api_request
        expect(response).to have_http_status :not_found
      end
    end
  end
end
