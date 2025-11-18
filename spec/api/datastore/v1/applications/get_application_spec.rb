require 'rails_helper'

RSpec.describe 'get application' do
  subject(:api_request) do
    get "/api/v1/applications/#{application_id}"
  end

  let(:application_id) { application.submitted_application['id'] }

  let(:application) do
    CrimeApplication.create!(submitted_application: submitted_application, submitted_at: 1.day.ago)
  end

  let(:submitted_application) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  let(:validator) { LaaCrimeSchemas::Validator.new(response.body, version: 1.0) }

  describe 'GET /api/applications/:application_id' do
    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-apply-preprod crime-review] do
      before { api_request }
    end

    context 'when found' do
      context 'when an initial application' do
        before { api_request }

        it 'returns http status 200' do
          expect(response).to have_http_status(:success)
        end

        it "returns the application's details" do
          expect(JSON.parse(response.body)['id']).to eq('696dd4fd-b619-4637-ab42-a5f4565bcf4a')
        end

        it 'returned details satisfy with schema' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end

      context 'when post submission evidence application' do
        before do
          CrimeApplication.create!(
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read), submitted_at: 1.day.ago
          )
          api_request
        end

        let(:submitted_application) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read) }

        it 'returns http status 200' do
          expect(response).to have_http_status(:success)
        end

        it "returns the application's details" do
          expect(JSON.parse(response.body)['id']).to eq('21c37e3e-520f-46f1-bd1f-5c25ffc57d70')
        end

        it 'returned details satisfy with schema' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end

      context 'when change in financial circumstances application' do
        before { api_request }

        let(:submitted_application) do
          JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'change_in_financial_circumstances').read)
        end

        it 'returns http status 200' do
          expect(response).to have_http_status(:success)
        end

        it "returns the application's details" do
          body = JSON.parse(response.body)

          expect(body['id']).to eq('98ab235c-f125-4dcb-9604-19e81782e53b')
          expect(body['pre_cifc_reference_number']).to eq('pre_cifc_maat_id')
          expect(body['pre_cifc_maat_id']).to eq('987654321')
          expect(body['pre_cifc_reason']).to eq('My client has a new job')
        end

        it 'returned details satisfy with schema' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end
    end

    context 'when a soft deleted application' do
      include_context 'with a consumer' do
        before do
          application.touch(:soft_deleted_at) # rubocop:disable Rails/SkipsModelValidations

          api_request
        end

        context 'when crime-review' do
          let(:consumer) { 'crime-review' }

          it 'returns http status 200' do
            expect(response).to have_http_status(:success)
          end
        end

        context 'when crime-apply' do
          let(:consumer) { 'crime-apply' }

          it_behaves_like 'an error that raises a 404 status code'
        end
      end
    end

    context 'when an archived application' do
      include_context 'with a consumer' do
        before do
          application.touch(:archived_at) # rubocop:disable Rails/SkipsModelValidations

          api_request
        end

        context 'when crime-review' do
          let(:consumer) { 'crime-review' }

          it 'returns http status 200' do
            expect(response).to have_http_status(:success)
          end
        end

        context 'when crime-apply' do
          let(:consumer) { 'crime-apply' }

          it_behaves_like 'an error that raises a 404 status code'
        end
      end
    end

    context 'when not found' do
      let(:application_id) { SecureRandom.uuid }

      before { api_request }

      it_behaves_like 'an error that raises a 404 status code'
    end
  end
end
