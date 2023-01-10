require 'rails_helper'

RSpec.describe 'list applications' do
  subject(:api_request) do
    get "/api/v2/applications#{query}"
  end

  let(:records_count) { JSON.parse(response.body).fetch('records').count }

  describe 'pagination' do
    subject(:pagination) do
      JSON.parse(response.body).fetch('pagination')
    end

    before do
      CrimeApplication.insert_all(
        Array.new(10) { { status: 'submitted' } } +
        Array.new(11) { { status: 'returned' } }
      )
      api_request
    end

    context 'without page param' do
      let(:query) { nil }

      it 'returns the first page of results with pagination headers' do
        expect(pagination['current_page']).to eq 1
        expect(pagination['total_count']).to eq 21
      end
    end

    context 'when page is specified' do
      let(:query) { '?page=2' }

      it 'returns the correct page' do
        expect(pagination['current_page']).to eq 2
        expect(records_count).to be 1
      end
    end

    context 'when page specified is out of range' do
      let(:query) { '?page=5' }

      it 'returns an empty page' do
        expect(pagination['current_page']).to eq 5
        expect(records_count).to be 0
      end
    end

    describe 'overiding the default per_page' do
      let(:query) { '?per_page=3' }

      it 'returns results according to specified per_page' do
        expect(pagination['total_pages']).to eq 7
        expect(records_count).to be 3
      end

      context 'when outside of range' do
        let(:query) { '?per_page=201' }

        it 'returns an error message' do
          expect(response).to have_http_status :bad_request
          expect(response.body).to match('per_page does not have a valid value')
        end
      end
    end
  end

  describe 'records' do
    subject(:records) do
      JSON.parse(response.body).fetch('records')
    end

    before do
      CrimeApplication.insert_all [
        {
          application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
          status: 'submitted', submitted_at: 1.day.ago, returned_at: nil
        },
        {
          application: {},
          status: 'returned', submitted_at: 1.week.ago, returned_at: Time.zone.now
        }
      ]

      get "/api/v2/applications#{query}"
    end

    let(:returned_statuses) { records.pluck('status').uniq }

    let(:query) { nil }

    it 'is an array of valid crime application details' do
      expect(
        LaaCrimeSchemas::Validator.new(records.first, version: 1.0)
      ).to be_valid
    end

    describe 'status filter' do
      it 'defaults to show all statuses' do
        expect(records.size).to be(2)
        expect(returned_statuses).to match %w[submitted returned]
      end

      CrimeApplication::STATUSES.each do |status|
        context "when '#{status}'" do
          let(:query) { "?status=#{status}" }

          it "returns only #{status} applications" do
            expect(records.size).to be(1)
            expect(returned_statuses).to match [status]
          end
        end
      end

      context 'when status provided not supported"' do
        let(:query) { '?status=deleted' }

        it 'an error is returned' do
          expect(response.body).to match 'status does not have a valid value'
        end
      end

      describe 'sort' do
        it 'defaults to descending' do
          expect(records.size).to be(2)
          expect(records.first['status']).to eq('submitted')
        end

        context 'when ascending is specified' do
          let(:query) { '?sort=ascending' }

          it 'the records are returned in ascending order' do
            expect(records.size).to be(2)
            expect(records.first['status']).to eq('returned')
          end
        end

        context 'when descending is specified' do
          let(:query) { '?sort=descending' }

          it 'the records are returned in descending order' do
            expect(records.size).to be(2)
            expect(records.first['status']).to eq('submitted')
          end
        end
      end
    end

    describe 'office_code filter' do
      context 'when office_code matches any application' do
        let(:query) { '?office_code=1A123B' }

        it 'returns only matching applications' do
          expect(records.size).to be(1)
          expect(
            records.first.dig('provider_details', 'office_code')
          ).to eq('1A123B')
        end
      end

      context 'when office_code does not match any application' do
        let(:query) { '?office_code=XYZ123' }

        it 'does not return applications' do
          expect(records.size).to be(0)
        end
      end
    end
  end

  describe 'order' do
    subject(:records) do
      JSON.parse(response.body).fetch('records')
    end

    before do
      CrimeApplication.insert_all [
        {
          application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
          status: 'submitted', submitted_at: 1.day.ago, returned_at: nil
        },
        {
          application: { 'client_details' => { 'applicant' => { 'last_name' => 'ZEBRA' } } },
          status: 'returned', submitted_at: 1.week.ago, returned_at: Time.zone.now
        }
      ]

      get "/api/v2/applications#{query}"
    end

    let(:query) { '?order=applicant_name&sort=descending' }

    it 'returns applications ordered by applicant last_name' do
      expect(records.size).to be(2)

      expect(
        records.first.dig('client_details', 'applicant', 'last_name')
      ).to eq('ZEBRA')

      expect(
        records.last.dig('client_details', 'applicant', 'last_name')
      ).to eq('Pound')
    end
  end
end
