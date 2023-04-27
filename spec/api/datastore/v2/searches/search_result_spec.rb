require 'rails_helper'

RSpec.describe 'Search results attributes' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: { search_text: '101' }, pagination: {} }
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:returned_id) { SecureRandom.uuid }
  let(:resubmission_id) { SecureRandom.uuid }
  let(:submitted_at) { 3.days.ago }
  let(:reviewed_at) { submitted_at + 1.hour }
  let(:resubmitted_at) { 2.days.ago }

  before do
    application = { reference: 101, client_details: { applicant: { first_name: 'Zoe', last_name: 'Bloggs' } } }

    # Insert returned application and it's resubmission
    CrimeApplication.insert_all(
      [
        {
          id: returned_id, status: 'returned', submitted_at: submitted_at,
          reviewed_at: reviewed_at, application: application
        },
        {
          id: resubmission_id, status: 'submitted', submitted_at: resubmitted_at,
          reviewed_at: nil, application: application.merge(parent_id: returned_id)
        }
      ]
    )

    api_request
  end

  it 'includes resource_id' do
    expect(records.pluck('resource_id')).to contain_exactly(resubmission_id, returned_id)
  end

  it 'includes applicant_name' do
    expect(records.first['applicant_name']).to eq 'Zoe Bloggs'
  end

  it 'includes parent_id' do
    expect(records.pluck('parent_id')).to contain_exactly(returned_id, nil)
  end

  it 'includes review status' do
    expect(records.pluck('review_status')).to eq %w[application_received application_received]
  end

  it 'includes reviewed_at' do
    expect(records.pluck('reviewed_at')).to contain_exactly(reviewed_at.iso8601, nil)
  end

  it 'includes reference' do
    expect(records.pluck('reference')).to eq [101, 101]
  end

  it 'includes status' do
    expect(records.pluck('status')).to contain_exactly 'submitted', 'returned'
  end

  it 'includes submitted_at' do
    expect(records.pluck('submitted_at')).to contain_exactly(resubmitted_at.iso8601, submitted_at.iso8601)
  end
end
