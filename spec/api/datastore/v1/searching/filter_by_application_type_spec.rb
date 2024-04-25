require 'rails_helper'

RSpec.describe 'searches filter by application type' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        { submitted_application: { application_type: 'initial' } },
        { submitted_application: { application_type: 'post_submission_evidence' } },
      ]
    )

    api_request
  end

  it 'defaults to returning all application types' do
    expect(records.count).to be 2
    expect(records.pluck('application_type').uniq).to match_array(%w[initial post_submission_evidence])
  end

  describe 'filtering by "initial"' do
    let(:search) { { application_type: ['initial'] } }

    it 'returns only "initial" applications' do
      expect(records.count).to be 1
      expect(records.pluck('application_type').uniq).to eq(['initial'])
    end
  end

  describe 'filtering by multiple application types' do
    let(:search) { { application_type: %w[initial post_submission_evidence] } }

    it 'returns records with a application_type in application_types' do
      expect(records.count).to be 2
      expect(records.pluck('application_type').uniq).to match_array(%w[initial post_submission_evidence])
    end
  end
end
