require 'rails_helper'

RSpec.describe 'searches filter by status' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [{ status: 'submitted' }, { status: 'returned' }, { status: 'returned' }]
    )

    api_request
  end

  it 'defaults to returning all statuses' do
    expect(records.count).to be 3
    expect(records.pluck('status').uniq).to eq(%w[submitted returned])
  end

  describe 'filtering by "returned"' do
    let(:search) { { status: ['returned'] } }

    it 'returns only "returned" applications' do
      expect(records.count).to be 2
      expect(records.pluck('status').uniq).to eq(['returned'])
    end
  end

  describe 'filtering by multiple statuses' do
    let(:search) { { status: %w[submitted returned] } }

    it 'returns records with a status in statuses' do
      expect(records.count).to be 3
      expect(records.pluck('status').uniq).to match(%w[submitted returned])
    end
  end
end
