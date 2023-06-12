require 'rails_helper'

RSpec.describe 'list applications' do
  subject(:api_request) do
    get "/api/v1/applications#{query}"
  end

  let(:query) { nil }
  let(:records_count) { JSON.parse(response.body).fetch('records').count }

  it_behaves_like 'an authorisable endpoint', %w[crime-apply] do
    before { api_request }
  end

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
      CrimeApplication.insert_all(applications)

      get "/api/v1/applications#{query}"
    end

    let(:applications) do
      [
        {
          submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
          status: 'submitted', submitted_at: 1.day.ago, returned_at: nil
        },
        {
          submitted_application: {},
          status: 'returned', submitted_at: 1.week.ago, returned_at: Time.zone.now
        },
        {
          submitted_application: {},
          status: 'superseded', submitted_at: 1.month.ago, returned_at: 1.week.ago
        }
      ]
    end

    let(:returned_statuses) { records.pluck('status').uniq }

    let(:query) { nil }

    it 'is an array of valid crime application details' do
      expect(
        LaaCrimeSchemas::Validator.new(records.first, version: 1.0, schema_name: 'pruned_application')
      ).to be_valid
    end

    describe 'pruned details' do
      let(:record) { records.first }

      context 'without unneeded attributes' do
        %w[
          provider_details case_details interests_of_justice return_details ioj_passport means_passport
        ].each do |name|
          it "does not have `#{name}` attribute" do
            expect(record.key?(name)).to be(false)
          end
        end
      end
    end

    describe 'status filter' do
      it 'defaults to show all statuses' do
        expect(records.size).to be(3)
        expect(returned_statuses).to match_array(%w[submitted returned superseded])
      end

      CrimeApplication.statuses.each_key do |status|
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
    end

    describe 'office_code filter' do
      context 'when office_code matches any application' do
        let(:query) { '?office_code=1A123B' }

        it 'returns only matching applications' do
          expect(records.size).to be(1)
        end
      end

      context 'when office_code does not match any application' do
        let(:query) { '?office_code=XYZ123' }

        it 'does not return applications' do
          expect(records.size).to be(0)
        end
      end
    end

    describe 'sorting' do
      let(:applications) do
        [
          {
            submitted_application: { submitted_at: 1.day.ago, returned_at: nil },
            status: 'submitted', submitted_at: 1.day.ago, returned_at: nil
          },
          {
            submitted_application: { submitted_at: 2.days.ago, returned_at: nil },
            status: 'submitted', submitted_at: 2.days.ago, returned_at: nil
          },
          {
            submitted_application: { submitted_at: 1.week.ago, returned_at: 8.days.ago },
            status: 'returned', submitted_at: 1.week.ago, returned_at: 8.days.ago
          },
          {
            submitted_application: { submitted_at: 2.weeks.ago, returned_at: 5.days.ago },
            status: 'returned', submitted_at: 2.weeks.ago, returned_at: 5.days.ago
          },
          {
            submitted_application: { submitted_at: 1.month.ago, returned_at: 3.weeks.ago },
            status: 'superseded', submitted_at: 1.month.ago, returned_at: 3.weeks.ago
          },
          {
            submitted_application: { submitted_at: 2.months.ago, returned_at: 7.weeks.ago },
            status: 'superseded', submitted_at: 2.months.ago, returned_at: 7.weeks.ago
          },
        ]
      end

      context 'when status is `submitted`' do
        context 'when sorting by `submitted_at`' do
          context 'when direction is `ascending`' do
            let(:query) { '?status=submitted&sort_by=submitted_at&sort_direction=asc' }

            it 'the records are returned in ascending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('submitted'))
              expect(records.first['submitted_at']).to be < records.second['submitted_at']
            end
          end

          context 'when direction is `descending`' do
            let(:query) { '?status=submitted&sort_by=submitted_at&sort_direction=desc' }

            it 'the records are returned in descending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('submitted'))
              expect(records.first['submitted_at']).to be > records.second['submitted_at']
            end
          end
        end
      end

      context 'when status is `returned`' do
        context 'when sorting by `submitted_at`' do
          context 'when direction is `ascending`' do
            let(:query) { '?status=returned&sort_by=submitted_at&sort_direction=asc' }

            it 'the records are returned in ascending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('returned'))
              expect(records.first['submitted_at']).to be < records.second['submitted_at']
            end
          end

          context 'when direction is `descending`' do
            let(:query) { '?status=returned&sort_by=submitted_at&sort_direction=desc' }

            it 'the records are returned in ascending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('returned'))
              expect(records.first['submitted_at']).to be > records.second['submitted_at']
            end
          end
        end

        context 'when sorting by `returned_at`' do
          context 'when direction is ascending' do
            let(:query) { '?status=returned&sort_by=returned_at&sort_direction=asc' }

            it 'the records are returned in ascending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('returned'))
              expect(records.first['returned_at']).to be < records.second['returned_at']
            end
          end

          context 'when direction is descending' do
            let(:query) { '?status=returned&sort_by=returned_at&sort_direction=desc' }

            it 'the records are returned in descending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('returned'))
              expect(records.first['returned_at']).to be > records.second['returned_at']
            end
          end
        end
      end

      # NOTE: all statuses behave the same, this is just a sanity check,
      # no need to test all combinations again for `superseded`
      context 'when status is `superseded`' do
        context 'when sorting by `submitted_at`' do
          context 'when direction is `ascending`' do
            let(:query) { '?status=superseded&sort_by=submitted_at&sort_direction=asc' }

            it 'the records are returned in ascending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('superseded'))
              expect(records.first['submitted_at']).to be < records.second['submitted_at']
            end
          end

          context 'when direction is `descending`' do
            let(:query) { '?status=superseded&sort_by=submitted_at&sort_direction=desc' }

            it 'the records are returned in descending order' do
              expect(records.size).to be(2)

              expect(records.pluck('status')).to all(eq('superseded'))
              expect(records.first['submitted_at']).to be > records.second['submitted_at']
            end
          end
        end
      end
    end
  end
end
