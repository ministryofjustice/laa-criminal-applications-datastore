require 'rails_helper'

RSpec.describe 'get application ready for maat' do
  describe 'GET /api/v1/maat/applications/:usn' do
    let(:api_request) { get "/api/v1/maat/applications/#{application_usn}" }

    let(:application) do
      CrimeApplication.create(
        submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
        review_status: :ready_for_assessment
      )
    end

    let(:application_usn) { application.submitted_application['reference'] }
    let(:maat_application) { JSON.parse(response.body) }

    it_behaves_like 'an authorisable endpoint', %w[maat-adapter maat-adapter-dev maat-adapter-uat] do
      before { api_request }
    end

    context 'with a ready for assessment application' do
      before do
        api_request
      end

      let(:expected_offence_class) do
        Utils::OffenceClassCalculator.new(
          offences: application.submitted_application['case_details']['offences']
        ).offence_class
      end

      # rubocop:disable Layout/LineLength
      let(:expected_case_details) do
        {
          'case_type' => application.submitted_application['case_details']['case_type'],
          'appeal_maat_id' => application.submitted_application['case_details']['appeal_maat_id'],
          'appeal_lodged_date' => application.submitted_application['case_details']['appeal_lodged_date'],
          'appeal_with_changes_details' => application.submitted_application['case_details']['appeal_with_changes_details'],
          'hearing_court_name' => application.submitted_application['case_details']['hearing_court_name'],
          'hearing_date' => application.submitted_application['case_details']['hearing_date'],
          'offence_class' => expected_offence_class,
          'urn' => application.submitted_application['case_details']['urn'],
          'date_case_concluded' => application.submitted_application['case_details']['date_case_concluded'],
          'has_case_concluded' => application.submitted_application['case_details']['has_case_concluded'],
          'is_client_remanded' => application.submitted_application['case_details']['is_client_remanded'],
          'date_client_remanded' => application.submitted_application['case_details']['date_client_remanded'],
          'is_preorder_work_claimed' => application.submitted_application['case_details']['is_preorder_work_claimed'],
          'preorder_work_date' => application.submitted_application['case_details']['preorder_work_date'],
          'preorder_work_details' => application.submitted_application['case_details']['preorder_work_details']
        }
      end
      # rubocop:enable Layout/LineLength

      let(:expected_maat_application) do
        {
          'application_type' => application.submitted_application['application_type'],
          'reference' => application.submitted_application['reference'],
          'reviewed_at' => application.reviewed_at,
          'client_details' => application.submitted_application['client_details'],
          'provider_details' => application.submitted_application['provider_details'],
          'submitted_at' => application.submitted_application['submitted_at'],
          'declaration_signed_at' => application.submitted_application['submitted_at'],
          'date_stamp' => application.submitted_application['date_stamp'],
          'means_passport' => application.submitted_application['means_passport'],
          'ioj_bypass' => application.submitted_application['interests_of_justice'].empty?,
          'case_details' => expected_case_details,
          'schema_version' => application.submitted_application['schema_version'],
          'id' => application.id
        }
      end

      it 'returns http status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns valid maat application details' do
        expect(
          LaaCrimeSchemas::Validator.new(response.body, version: 1.0, schema_name: 'maat_application')
        ).to be_valid
      end

      it 'returns the required application details for maat integration' do
        expect(maat_application).to match(expected_maat_application)
      end
    end

    context 'with a completed application' do
      before do
        application.update!(review_status: :assessment_completed, reviewed_at: 1.week.ago)
        api_request
      end

      it 'returns http status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the completed application' do
        expect(maat_application['reference']).to match(application.submitted_application['reference'])
      end
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

    context 'when the application is not found' do
      let(:application_usn) { '12345' }

      it_behaves_like 'an error that raises a 404 status code' do
        before { api_request }
      end
    end
  end
end
