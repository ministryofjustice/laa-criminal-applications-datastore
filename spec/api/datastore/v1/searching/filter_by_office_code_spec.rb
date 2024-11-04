require 'rails_helper'

RSpec.describe 'searches filter by office code' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        { submitted_application: { provider_details: { office_code: 'AB12C' } } },
        { submitted_application: { provider_details: { office_code: 'ZX45Y' } } },
      ]
    )

    api_request
  end

  it 'defaults to returning all office codes' do
    expect(records.count).to be 2
    expect(records.pluck('office_code').uniq).to match_array(%w[AB12C ZX45Y])
  end

  describe 'filtering by `AB12C` office code' do
    let(:search) { { office_code: 'AB12C' } }

    it 'returns only applications with office code `AB12C`' do
      expect(records.count).to be 1
      expect(records.pluck('office_code').uniq).to eq(['AB12C'])
    end
  end
end
