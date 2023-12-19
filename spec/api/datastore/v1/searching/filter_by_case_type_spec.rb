require 'rails_helper'

RSpec.describe 'searches filter by case type' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        { submitted_application: { case_details: { case_type:  Types::CaseType['summary_only'] } } },
        { submitted_application: { case_details: { case_type:  Types::CaseType['either_way'] } } },
      ]
    )

    api_request
  end

  it 'defaults to returning all case types' do
    expect(records.count).to be 2
    expect(records.pluck('case_type').uniq).to match_array(%w[summary_only either_way])
  end

  describe 'filtering by "summary_only"' do
    let(:search) { { case_type: ['summary_only'] } }

    it 'returns only "summary_only" applications' do
      expect(records.count).to be 1
      expect(records.pluck('case_type').uniq).to eq(['summary_only'])
    end
  end

  describe 'filtering by multiple case types' do
    let(:search) { { case_type: %w[summary_only either_way] } }

    it 'returns records with a case_type in case_types' do
      expect(records.count).to be 2
      expect(records.pluck('case_type').uniq).to match_array(%w[summary_only either_way])
    end
  end
end
