require 'rails_helper'

RSpec.describe 'searches filter by submitted_at' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: search, pagination: {} }
  end

  let(:search) { {} }
  let(:records) { JSON.parse(response.body).fetch('records') }

  before do
    CrimeApplication.insert_all(
      [
        { submitted_at: 3.days.ago, application: { reference: 101 } },
        { submitted_at: 2.days.ago, application: { reference: 102 } },
        { submitted_at: 1.day.ago, application: { reference: 103 } }
      ]
    )

    api_request
  end

  it 'defaults to showing all applications' do
    expect(records.pluck('reference')).to match_array([101, 102, 103])
  end

  context 'when submitted_after is provided' do
    let(:search) { { submitted_after: 2.days.ago } }

    it 'only shows records submitted after' do
      expect(records.pluck('reference')).to match_array([102, 103])
    end
  end

  context 'when submitted_before is provided' do
    let(:search) { { submitted_before: 2.days.ago } }

    it 'only shows records submitted before' do
      expect(records.pluck('reference')).to eq([101])
    end
  end
end
