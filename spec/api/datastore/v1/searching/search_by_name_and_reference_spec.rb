require 'rails_helper'

RSpec.describe 'search with text' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:search) { { search_text: '' } }
  let(:records) { JSON.parse(response.body).fetch('records') }

  before do
    details = %i[Jenni Deere 1010 David Brown 1020 Jenny Deere 1030].each_slice(3)
    CrimeApplication.insert_all(
      details.map do |first_name, last_name, reference|
        {
          application: {
            client_details: {
              applicant: { first_name:, last_name: }
            },
            reference: reference
          }
        }
      end
    )

    api_request
  end

  it_behaves_like 'an authorisable endpoint', %w[crime-review]

  it 'defaults to showing all applications' do
    expect(records.count).to be 3
    expect(records.pluck('resource_id')).to match_array(CrimeApplication.pluck(:id))
  end

  context 'when first name is searched' do
    let(:search) { { search_text: 'jENNi' } }

    it 'shows results that match the first name or alternative spelling' do
      expect(records.pluck('reference')).to contain_exactly(1010, 1030)
    end
  end

  context 'when reference is included' do
    let(:search) { { search_text: 'Jenni dEEre 1030' } }

    it 'shows results that match the reference name' do
      expect(records.pluck('reference')).to match([1030])
    end
  end

  context 'when last_name is searched' do
    let(:search) { { search_text: 'DEERE' } }

    it 'shows results that match the last name' do
      expect(records.pluck('reference')).to contain_exactly(1010, 1030)
    end
  end

  context 'when first and last name are searched' do
    let(:search) { { search_text: 'jEnNi DEEre' } }

    it 'shows results that match the full name' do
      expect(records.pluck('reference')).to contain_exactly(1010, 1030)
    end
  end

  context 'when a name is indexed differently' do
    let(:search) { { search_text: 'Jenny', status: ['submitted'] } }

    it 'shows results that match the full name' do
      expect(records.pluck('reference')).to contain_exactly(1010, 1030)
    end
  end
end
