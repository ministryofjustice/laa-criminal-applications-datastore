require 'rails_helper'

RSpec.describe 'searches filter by review status' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        { review_status: 'application_received' },
        { review_status: 'returned_to_provider' },
        { review_status: 'returned_to_provider' },
        { review_status: 'ready_for_assessment' }
      ]
    )

    api_request
  end

  it 'defaults to returning all statuses' do
    expect(records.count).to be 4
    expect(records.pluck('review_status').uniq).to eq(%w[application_received returned_to_provider
                                                         ready_for_assessment])
  end

  describe 'filtering by "returned_to_provider"' do
    let(:search) { { review_status: ['returned_to_provider'] } }

    it 'returns only "returned" applications' do
      expect(records.count).to be 2
      expect(records.pluck('review_status').uniq).to eq(['returned_to_provider'])
    end
  end

  describe 'filtering by multiple statuses' do
    let(:search) { { review_status: %w[application_received ready_for_assessment] } }

    it 'returns records with a status in statuses' do
      expect(records.count).to be 2
      expect(records.pluck('review_status').uniq).to eq(%w[application_received ready_for_assessment])
    end
  end
end
