require 'rails_helper'

RSpec.describe 'search by maat_id' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:search) { { search_text: '' } }
  let(:records) { JSON.parse(response.body).fetch('records') }

  let(:app_with_legacy_maat_id) do
    CrimeApplication.create!(
      submitted_application: LaaCrimeSchemas.fixture(1.0) do |json|
        json.deep_merge(
          'id' => SecureRandom.uuid,
          'reference' => 6001,
          'client_details' => { 'applicant' => { 'first_name' => 'Alice', 'last_name' => 'Smith' } }
        )
      end,
      maat_id: 1_234_567
    )
  end

  let(:app_with_decision_maat_id) do
    app = CrimeApplication.create!(
      submitted_application: LaaCrimeSchemas.fixture(1.0) do |json|
        json.deep_merge(
          'id' => SecureRandom.uuid,
          'reference' => 6002,
          'client_details' => { 'applicant' => { 'first_name' => 'Bob', 'last_name' => 'Jones' } }
        )
      end
    )
    Decision.create!(
      crime_application: app,
      reference: 6002,
      maat_id: 7_654_321,
      funding_decision: 'granted'
    )
    app
  end

  let(:app_with_no_maat_id) do
    CrimeApplication.create!(
      submitted_application: LaaCrimeSchemas.fixture(1.0) do |json|
        json.deep_merge(
          'id' => SecureRandom.uuid,
          'reference' => 6003,
          'client_details' => { 'applicant' => { 'first_name' => 'Carol', 'last_name' => 'White' } }
        )
      end
    )
  end

  before do
    app_with_legacy_maat_id
    app_with_decision_maat_id
    app_with_no_maat_id
    api_request
  end

  it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-apply-preprod crime-review]

  context 'when searching by a legacy maat_id (crime_applications.maat_id)' do
    let(:search) { { search_text: '1234567' } }

    it 'returns only the matching application' do
      expect(records.pluck('reference')).to contain_exactly(6001)
    end
  end

  context 'when searching by a decision maat_id (decisions.maat_id)' do
    let(:search) { { search_text: '7654321' } }

    it 'returns only the matching application' do
      expect(records.pluck('reference')).to contain_exactly(6002)
    end
  end

  context 'when there are no applications with that maat_id' do
    let(:search) { { search_text: '9999999' } }

    it 'returns no results' do
      expect(records).to be_empty
    end
  end

  context 'when searching by maat_id combined with applicant name' do
    let(:search) { { search_text: 'Alice 1234567' } }

    it 'returns the matching application' do
      expect(records.pluck('reference')).to contain_exactly(6001)
    end
  end
end
