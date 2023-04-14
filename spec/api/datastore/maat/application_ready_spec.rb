require 'rails_helper'

RSpec.describe 'get application ready for maat' do
  describe 'GET /api/maat/applications/:usn' do
    let(:api_request) { get "/api/maat/applications/#{application_usn}" }

    let(:application) do
      CrimeApplication.create(
        application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
        review_status: :ready_for_assessment,
        id: SecureRandom.uuid,
        submitted_at: 1.day.ago
      )
    end

    let(:application_usn) { application.application['reference'] }
    let(:maat_application) { JSON.parse(response.body) }

    context 'with a ready for assessment application' do
      before do
        api_request
      end

      let(:expected_offence_class) do
        Helpers::OffenceClassCalculator.new(offences: application.application['case_details']['offences']).offence_class
      end

      let(:expected_case_details) do
        {
          'appeal_maat_id' => application.application['case_details']['appeal_maat_id'],
          'case_type' => application.application['case_details']['case_type'],
          'hearing_court_name' => application.application['case_details']['hearing_court_name'],
          'hearing_date' => application.application['case_details']['hearing_date'],
          'offence_class' => expected_offence_class,
          'urn' => application.application['case_details']['urn'],
        }
      end

      let(:expected_maat_application) do
        {
          'reference' => application.application['reference'],
          'client_details' => application.application['client_details'],
          'provider_details' => application.application['provider_details'],
          'submitted_at' => application['submitted_at'].iso8601,
          'date_stamp' => application.application['date_stamp'],
          'ioj_passport' => application.application['ioj_passport'],
          'interests_of_justice' => application.application['interests_of_justice'],
          'case_details' => expected_case_details,
          'schema_version' => 1.0,
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
