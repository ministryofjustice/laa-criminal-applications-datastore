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

      context 'when the decisions are invalid' do
        let(:decisions) do
          [
            {
              'reference' => 1234,
              'maat_id' => 5678,
              'case_id' => '123123123',
              'interests_of_justice' => nil,
              'means' => nil,
              'funding_decision' => nil,
              'comment' => 'test comment'
            },
            {
              'reference' => nil,
              'maat_id' => nil,
              'case_id' => '123123123',
              'interests_of_justice' => {
                'result' => 'passed',
                'assessed_by' => 'Kory liam'
              },
              'means' => nil,
              'funding_decision' => 'granted',
              'comment' => 'test comment'
            }
          ].to_json
        end

        it 'does not update the application' do
          expect { api_request }
            .to(
              not_change { application.reload.review_status }
              .and(not_change { application.reload.reviewed_at })
            )
        end

        it 'returns 400' do
          api_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns error information' do
          api_request
          expect(response.body).to include(
            "The property '#/0/funding_decision' of type null did not match the following type: string in schema",
            "The property '#/1/interests_of_justice' did not contain a required property of 'assessed_on'"
          )
        end
      end

      context 'when the decisions are valid' do
        let(:decisions) do
          [
            {
              'reference' => 1234,
              'maat_id' => 5678,
              'case_id' => '123123123',
              'interests_of_justice' => interests_of_justice,
              'means' => means,
              'funding_decision' => 'granted',
              'comment' => 'test comment',
              'assessment_rules' => 'appeal_to_crown_court',
              'overall_result' => 'granted_failed_means'
            }.as_json
          ]
        end

        let(:interests_of_justice) do
          {
            'result' => 'passed',
            'details' => 'decision details',
            'assessed_by' => 'Grace Nolan',
            'assessed_on' => '2024-10-01 00:00:00'
          }
        end

        let(:means) do
          {
            'result' => 'failed',
            'details' => 'means details',
            'assessed_by' => 'Kory Liam',
            'assessed_on' => '2024-11-01 00:00:00'
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

        it 'persists the decisions' do # rubocop:disable RSpec/MultipleExpectations
          api_request
          decisions = application.reload.decisions
          expect(decisions.size).to eq(1)
          expect(decisions.first.reference).to eq(1234)
          expect(decisions.first.maat_id).to eq(5678)
          expect(decisions.first.case_id).to eq('123123123')
          expect(decisions.first.interests_of_justice).to eq(interests_of_justice)
          expect(decisions.first.means).to eq(means)
          expect(decisions.first.funding_decision).to eq('granted')
          expect(decisions.first.comment).to eq('test comment')
          expect(decisions.first.assessment_rules).to eq('appeal_to_crown_court')
          expect(decisions.first.overall_result).to eq(Types::OverallResult['granted_failed_means'])
        end
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
