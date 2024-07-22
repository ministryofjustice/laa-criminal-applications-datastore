require 'rails_helper'

RSpec.describe 'get application ready for maat' do
  describe 'GET /api/v1/maat/applications/:usn' do
    let(:api_request) { get "/api/v1/maat/applications/#{application_usn}" }

    let(:application) do
      CrimeApplication.create(
        submitted_application: submitted_application,
        review_status: :ready_for_assessment
      )
    end

    let(:submitted_application) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
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

      it 'returns http status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns valid maat application details' do
        expect(
          LaaCrimeSchemas::Validator.new(response.body, version: 1.0, schema_name: 'maat_application')
        ).to be_valid
      end
    end

    context 'with a non-means application' do
      let(:submitted_application) do
        super().deep_merge(
          'is_means_tested' => 'no',
          'means_passport' => %w[on_benefit_check on_not_means_tested]
        )
      end

      before { api_request }

      it 'returns http status Unprocessable Entity' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/did not match one of the following values: on_age_under18, on_benefit_check/)
      end
    end

    describe 'returning the calcuated offence class' do
      let(:offence_class) { Types::OffenceClass.values.sample }

      before do
        allow(Utils::OffenceClassCalculator).to receive(:new).and_return(
          instance_double(Utils::OffenceClassCalculator, offence_class:)
        )
        api_request
      end

      it 'is included in the case_details' do
        expect(maat_application['case_details']['offence_class']).to eq(offence_class)
      end
    end

    context 'with a completed application' do
      before do
        application.update!(
          review_status: :assessment_completed,
          reviewed_at: DateTime.new(2022, 12, 1, 12, 28, 58.001)
        )
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
