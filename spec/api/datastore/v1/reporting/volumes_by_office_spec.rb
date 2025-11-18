require 'rails_helper'

RSpec.describe 'Monthly submissions by office code' do
  subject(:api_request) do
    get "/api/v1/reporting/volumes_by_office/monthly/#{period}", params:
  end

  let(:data) { JSON.parse(response.body).fetch('data') }
  let(:params) { {} }
  let(:period) { '2025-May' }
  let(:date) { Date.new(2025, 0o5, 11).in_time_zone('London') }

  it_behaves_like 'an authorisable endpoint', 'crime-review' do
    before { api_request }
  end

  before do
    period_start = date.beginning_of_month.utc
    period_end = date.end_of_month.utc

    # rubocop:disable Rails/SkipsModelValidations
    CrimeApplication.insert_all(
      [period_start, period_start - 1.second, period_end, period_end + 1.second].map do |submitted_at|
        {
          submitted_application: {
            application_type: 'initial', provider_details: { office_code: '1A2B3C' }
          },
          submitted_at: submitted_at
        }
      end
    )

    CrimeApplication.insert_all([
                                  {
                                    submitted_application: {
                                      application_type: 'change_in_financial_circumstances',
                                      provider_details: { office_code: '1A2CFC' }
                                    },
                                    submitted_at: period_start
                                  },
                                  {
                                    submitted_application: {
                                      application_type: 'post_submission_evidence',
                                      provider_details: { office_code: '1A2P5E' }
                                    },
                                    submitted_at: period_end
                                  }

                                ])
    # rubocop:enable Rails/SkipsModelValidations

    api_request
  end

  describe 'whith the default application types' do
    it 'returns the volumes by office report for the given period excluding PSE' do
      expect(data).to eq({ '1A2B3C' => 2, '1A2CFC' => 1 })
    end
  end

  describe 'when application types are specified' do
    let(:params) { { application_types: ['post_submission_evidence'] } }

    it 'volumes are scoped by them rather than the default application types' do
      expect(data).to eq({ '1A2P5E' => 1 })
    end
  end

  describe 'when application types are not valid' do
    let(:params) { { application_types: ['not_a_type'] } }

    it 'return a bad request error' do
      expect(response).to have_http_status :bad_request
      expect(JSON.parse(response.body)['error']).to eq(
        'application_types does not have a valid value'
      )
    end
  end

  describe 'when period is not in year-month format' do
    let(:period) { 'May-2022' }

    it 'return a bad request error' do
      expect(response).to have_http_status :bad_request
      expect(JSON.parse(response.body)['error']).to eq(
        "period must be in '%Y-%B' format (e.g. '2025-November')"
      )
    end
  end
end
