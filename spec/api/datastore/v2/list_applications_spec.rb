require 'rails_helper'

RSpec.describe 'list applications' do
  subject(:api_request) do
    get "/api/v2/applications#{page_query}"
  end

  describe 'pagination' do
    subject(:pagination) do
      JSON.parse(response.body).fetch('pagination')
    end

    let(:records_count) { JSON.parse(response.body).fetch('records').count }

    before do
      # rubocop:disable Rails/SkipsModelValidations
      CrimeApplication.insert_all(
        Array.new(21) { { application: { status: 'submitted' } } }
      )
      # rubocop:enable Rails/SkipsModelValidations
      api_request
    end

    context 'without page param' do
      let(:page_query) { nil }

      it 'returns the first page of results with pagination headers' do
        expect(pagination['current_page']).to eq 1
        expect(pagination['total_count']).to eq 21
      end
    end

    context 'when page is specified' do
      let(:page_query) { '?page=2' }

      it 'returns the correct page' do
        expect(pagination['current_page']).to eq 2
        expect(records_count).to be 1
      end
    end

    context 'when page specified is out of range' do
      let(:page_query) { '?page=5' }

      it 'returns an empty page' do
        expect(pagination['current_page']).to eq 5
        expect(records_count).to be 0
      end
    end

    describe 'overiding the default per_page' do
      let(:page_query) { '?per_page=3' }

      it 'returns results according to specified per_page' do
        expect(pagination['total_pages']).to eq 7
        expect(records_count).to be 3
      end

      context 'when outside of range' do
        let(:page_query) { '?per_page=201' }

        it 'returns an error message' do
          expect(response).to have_http_status :bad_request
          expect(response.body).to match('per_page does not have a valid value')
        end
      end
    end
  end

  describe 'records' do
    subject(:records) do
      JSON.parse(response.body).fetch('records')
    end

    before do
      CrimeApplication.create(
        application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
      )

      get '/api/v2/applications'
    end

    it 'is an array of valid crime application details' do
      expect(
        LaaCrimeSchemas::Validator.new(records.first, version: 1.0)
      ).to be_valid
    end
  end
end
