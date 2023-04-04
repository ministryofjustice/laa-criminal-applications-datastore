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

      it 'returns http status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns valid maat application details' do
        expect(
          LaaCrimeSchemas::Validator.new(response.body, version: 1.0, schema_name: 'maat_application')
        ).to be_valid
      end

      it 'returns the required application details for maat integration' do
        expect(maat_application['reference']).to match(application.application['reference'])
        expect(maat_application['client_details']).to match(application.application['client_details'])
        expect(maat_application['provider_details']).to match(application.application['provider_details'])
        expect(maat_application['submitted_at']).to match(application['submitted_at'].iso8601)
        expect(maat_application['date_stamp']).to match(application.application['date_stamp'])
        expect(maat_application['ioj_passport']).to match(application.application['ioj_passport'])
        expect(maat_application['interests_of_justice']).to match(application.application['interests_of_justice'])
      end

      it 'returns the required case details for maat integration' do
        expect(maat_application['case_details']).to match(
          {
            'appeal_maat_id' => application.application['case_details']['appeal_maat_id'],
            'case_type' => application.application['case_details']['case_type'],
            'hearing_court_name' => application.application['case_details']['hearing_court_name'],
            'hearing_date' => application.application['case_details']['hearing_date'],
            'offence_class' => application.application['case_details']['offence_class'],
            'urn' => application.application['case_details']['urn'],
          }
        )
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
