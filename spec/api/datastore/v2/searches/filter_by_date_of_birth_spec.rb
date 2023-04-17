require 'rails_helper'

RSpec.describe 'filter search by applicant date of birth' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }

  before do
    CrimeApplication.insert_all(
      [
        { status: 'submitted', application: {} },
        { status: 'submitted', application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read) },
        { status: 'returned', application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
      ]
    )

    api_request
  end

  context 'when empty' do
    let(:search) { { applicant_date_of_birth: '' } }

    it 'shows all applications' do
      expect(records.count).to be 3
    end
  end

  context 'when a known date of birth is given' do
    let(:search) do
      { applicant_date_of_birth: '2001-06-09' }
    end

    it 'returns matching records' do
      expect(records.count).to be 2
    end
  end
end
