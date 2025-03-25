require 'rails_helper'

RSpec.describe 'Searches include or exclude archived applications' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        { archived: true, archived_at: Time.zone.now, submitted_application: { reference: 101 } },
        { archived: false, archived_at: nil, submitted_application: { reference: 102 } },
      ]
    )

    api_request
  end

  it 'defaults to include archived applications' do
    expect(records.count).to be 2
    expect(records.pluck('reference')).to contain_exactly(101, 102)
  end

  describe 'excluding archived applications' do
    let(:search) { { exclude_archived: 'true' } }

    it 'returns only applications that are not archived' do
      expect(records.count).to be 1
      expect(records.pluck('reference')).to eq([102])
    end
  end
end
