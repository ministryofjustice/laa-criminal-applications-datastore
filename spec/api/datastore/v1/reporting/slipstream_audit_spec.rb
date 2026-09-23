require 'rails_helper'

RSpec.describe 'Slipstream audit report by month' do
  subject(:api_request) do
    get "/api/v1/reporting/slipstream_audit/monthly/#{period}", params:
  end

  let(:data) { JSON.parse(response.body).fetch('data') }
  let(:offence_sampling) { JSON.parse(response.body).fetch('offence_sampling') }
  let(:params) { {} }
  let(:period) { '2025-May' }
  let(:in_period) { Date.new(2025, 5, 11).in_time_zone('London') }
  let(:out_of_period) { Date.new(2025, 6, 1).in_time_zone('London') }

  it_behaves_like 'an authorisable endpoint', 'crime-review' do
    before { api_request }
  end

  before do
    create_outcome(
      business_reference: 1, status: 'confirmed', submitted_at: in_period,
      offences: [{ 'name' => 'Robbery', 'offence_class' => 'C', 'slipstreamable' => true }]
    )
    create_outcome(
      business_reference: 2, status: 'withdrawn', submitted_at: in_period,
      offences: [{ 'name' => 'Robbery', 'offence_class' => 'C', 'slipstreamable' => true }]
    )
    create_outcome(business_reference: 3, status: 'confirmed', submitted_at: out_of_period)

    api_request
  end

  def create_outcome(**attrs)
    SlipstreamAuditSelectionOutcome.create!(
      {
        crime_application_id: SecureRandom.uuid,
        office_code: '1A2B3C',
        application_type: 'initial',
        sample_rate: 10,
        sampled_at: attrs.fetch(:submitted_at),
        status_determined_at: attrs.fetch(:submitted_at)
      }.merge(attrs)
    )
  end

  describe 'with the default status' do
    it 'returns confirmed outcomes submitted in the period' do
      expect(data.pluck('reference')).to eq([1])
    end
  end

  describe 'the offence sampling aggregate' do
    it 'counts confirmed applications per offence across the period' do
      expect(offence_sampling).to eq(
        [{ 'offence' => 'Robbery', 'confirmed_applications' => 1 }]
      )
    end
  end

  describe 'when a status is specified' do
    let(:params) { { status: 'withdrawn' } }

    it 'returns outcomes with that status in the period' do
      expect(data.pluck('reference')).to eq([2])
    end
  end

  describe 'when the status is not valid' do
    let(:params) { { status: 'not_a_status' } }

    it 'returns a bad request error' do
      expect(response).to have_http_status :bad_request
      expect(JSON.parse(response.body)['error']).to eq('status does not have a valid value')
    end
  end

  describe 'when period is not in year-month format' do
    let(:period) { 'May-2022' }

    it 'returns a bad request error' do
      expect(response).to have_http_status :bad_request
      expect(JSON.parse(response.body)['error']).to eq(
        "period must be in '%Y-%B' format (e.g. '2025-November')"
      )
    end
  end
end
