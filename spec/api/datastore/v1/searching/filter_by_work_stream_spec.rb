require 'rails_helper'

RSpec.describe 'searches filter by work stream' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        { work_stream: Types::WorkStreamType['criminal_applications_team'],
submitted_application: { first_court_hearing_name: 'Cardiff Crown Court' } },
        { work_stream: Types::WorkStreamType['extradition'],
submitted_application: { first_court_hearing_name: "Westminster Magistrates' Court" } },
      ]
    )

    api_request
  end

  it 'defaults to returning all work streams' do
    expect(records.count).to be 2
    expect(records.pluck('work_stream').uniq).to match_array(%w[criminal_applications_team extradition])
  end

  describe 'filtering by "extradition"' do
    let(:search) { { work_stream: ['extradition'] } }

    it 'returns only "extradition" applications' do
      expect(records.count).to be 1
      expect(records.pluck('work_stream').uniq).to eq(['extradition'])
    end
  end

  describe 'filtering by multiple work streams' do
    let(:search) { { work_stream: %w[criminal_applications_team extradition] } }

    it 'returns records with a work_stream in work_streams' do
      expect(records.count).to be 2
      expect(records.pluck('work_stream').uniq).to match_array(%w[criminal_applications_team extradition])
    end
  end
end
