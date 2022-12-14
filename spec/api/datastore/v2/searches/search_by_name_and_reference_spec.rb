require 'rails_helper'

RSpec.describe 'search with text' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: search, pagination: {} }
  end

  let(:search) { { search_text: '' } }
  let(:records) { JSON.parse(response.body).fetch('records') }

  before do
    details = %i[John Deere 1010 Ken John 1020 Jonathan Deere 1030].each_slice(3)
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

  it 'defaults to showing all applications' do
    expect(records.count).to be 3
    expect(records.pluck('resource_id')).to match(
      CrimeApplication.pluck(:id)
    )
  end

  context 'when first name is searched' do
    let(:search) { { search_text: 'John' } }

    it 'shows results that match the first name' do
      expect(records.pluck('reference')).to match([1010, 1020])
    end
  end

  context 'when reference is included' do
    let(:search) { { search_text: 'Deere 1030' } }

    it 'shows results that match the reference name' do
      expect(records.pluck('reference')).to match([1030])
    end
  end

  context 'when last_name is searched' do
    let(:search) { { search_text: 'Deere' } }

    it 'shows results that match the last name' do
      expect(records.pluck('reference')).to match([1010, 1030])
    end
  end

  context 'when first and last name are searched' do
    let(:search) { { search_text: 'John Deere' } }

    it 'shows results that match the full name' do
      expect(records.pluck('reference')).to match([1010])
    end
  end
end
