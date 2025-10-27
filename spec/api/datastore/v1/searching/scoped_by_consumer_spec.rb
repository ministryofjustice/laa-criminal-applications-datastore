require 'rails_helper'

RSpec.describe 'scope search by consumer' do
  subject(:api_request) do
    post '/api/v1/searches', params: { search: search, pagination: {} }
  end

  include_context 'with a consumer'

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:search) { {} }

  before do
    CrimeApplication.insert_all(
      [
        {
          submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
          status: 'submitted', submitted_at: 1.day.ago, returned_at: nil,
          archived_at: nil, soft_deleted_at: nil
        },
        {
          submitted_application: { reference: 6_000_002 },
          status: 'returned', submitted_at: 1.week.ago, returned_at: Time.zone.now,
          archived_at: Time.zone.now, soft_deleted_at: nil
        },
        {
          submitted_application: { reference: 6_000_003 },
          status: 'superseded', submitted_at: 1.month.ago, returned_at: 1.week.ago,
          archived_at: nil, soft_deleted_at: nil
        },
        {
          submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge('reference' => 6_000_004),
          status: 'returned', submitted_at: 1.year.ago, returned_at: 1.year.ago,
          archived_at: nil, soft_deleted_at: 1.day.ago
        }
      ]
    )

    api_request
  end

  context 'when the consumer is crime-apply' do
    let(:consumer) { 'crime-apply' }

    it 'excludes archived applications' do
      expect(records.size).to be(2)
      expect(records.pluck('reference')).to contain_exactly(6_000_001, 6_000_003)
    end
  end

  context 'when the consumer is not crime-apply' do
    let(:consumer) { 'crime-review' }

    it 'includes all applications' do
      expect(records.size).to be(4)
      expect(records.pluck('reference')).to contain_exactly(
        6_000_001, 6_000_002, 6_000_003, 6_000_004
      )
    end
  end
end
