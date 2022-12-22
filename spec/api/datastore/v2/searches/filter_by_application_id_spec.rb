require 'rails_helper'

RSpec.describe 'searches filter by id' do
  subject(:api_request) do
    post '/api/v2/searches', params: { search: search, pagination: {} }
  end

  let(:search) { {} }
  let(:records) { JSON.parse(response.body).fetch('records') }

  before do
    CrimeApplication.insert_all(
      Array.new(3) { { id: SecureRandom.uuid } }
    )

    api_request
  end

  it 'defaults to showing all applications' do
    expect(records.count).to be 3
    expect(records.pluck('resource_id')).to match(
      CrimeApplication.pluck(:id)
    )
  end

  describe 'filter by application_id_in' do
    context 'when known applications_ids are provided' do
      let(:extant_ids) { CrimeApplication.limit(2).pluck(:id).to_a }
      let(:search) do
        {
          application_id_in: extant_ids.dup << SecureRandom.uuid
        }
      end

      it 'only shows results that match the application_id' do
        expect(records.count).to be 2
        expect(records.pluck('resource_id')).to match(extant_ids)
      end
    end
  end

  describe 'filter by application_id_not_in' do
    context 'when known applications_ids are provided' do
      let(:excluded_ids) { CrimeApplication.limit(2).pluck(:id).to_a }
      let(:search) do
        {
          application_id_not_in: excluded_ids.dup << SecureRandom.uuid
        }
      end

      it 'only shows applications that are not in the excluded_ids' do
        expect(records.count).to be 1

        expect(records.pluck('resource_id')).to match(
          CrimeApplication.pluck(:id) - excluded_ids
        )
      end
    end
  end
end
