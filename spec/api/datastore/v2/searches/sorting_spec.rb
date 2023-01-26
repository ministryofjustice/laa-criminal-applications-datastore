require 'rails_helper'

RSpec.describe 'Sorting applications' do
  subject(:api_request) do
    post '/api/v2/searches', params: {
      search: search, sorting: sorting_params
    }
  end

  let(:sorting_params) do
    {
      sort_direction: 'descending',
      sort_by: 'submitted_at'
    }
  end

  let(:search) do
    {}
  end

  let(:records) { JSON.parse(response.body).fetch('records') }
  let(:records_count) { records.count }

  let(:applications) do
    [
      {
        application: {},
        status: 'submitted', submitted_at: 1.day.ago, returned_at: nil,
        reviewed_at: nil
      },
      {
        application: {},
        status: 'submitted', submitted_at: 2.days.ago, returned_at: nil,
        reviewed_at: nil
      },
      {
        application: {},
        status: 'returned', submitted_at: 1.week.ago, returned_at: 8.days.ago,
        reviewed_at: 8.days.ago
      },
      {
        application: {},
        status: 'returned', submitted_at: 2.weeks.ago, returned_at: 5.days.ago,
        reviewed_at: 5.days.ago
      },
    ]
  end

  before do
    CrimeApplication.insert_all(applications)
    api_request
  end

  describe 'sorting' do
    subject(:sorting) do
      JSON.parse(response.body).fetch('sorting')
    end

    describe 'default sorting' do
      it 'defaults to submitted_at and descending' do
        expected_result = {
          'sort_direction' => 'descending',
          'sort_by' => 'submitted_at'
        }
        expect(sorting).to eq(expected_result)
      end
    end

    describe 'Setting sort params' do
      let(:sorting_params) do
        {
          'sort_direction' => 'ascending',
          'sort_by' => 'reviewed_at'
        }
      end

      it 'applies the params' do
        expected_result = {
          'sort_direction' => 'ascending',
          'sort_by' => 'reviewed_at'
        }
        expect(sorting).to eq(expected_result)
      end
    end

    context 'when a search is performed' do
      let(:search) do
        {
          status: %w[submitted returned]
        }
      end

      context 'when sorting by `submitted_at`' do
        context 'when direction is `ascending`' do
          let(:sorting_params) do
            {
              'sort_direction' => 'ascending',
              'sort_by' => 'submitted_at'
            }
          end

          it 'the records are returned in ascending order' do
            expect(records_count).to be(4)

            expect(records.first['submitted_at']).to be < records.second['submitted_at']
          end
        end

        context 'when direction is `descending`' do
          let(:sorting_params) do
            {
              'sort_direction' => 'descending',
              'sort_by' => 'submitted_at'
            }
          end

          it 'the records are returned in ascending order' do
            expect(records.size).to be(4)

            expect(records.first['submitted_at']).to be > records.second['submitted_at']
          end
        end
      end

      context 'when sorting by `reviewed_at`' do
        context 'when direction is `ascending`' do
          let(:sorting_params) do
            {
              'sort_direction' => 'ascending',
              'sort_by' => 'reviewed_at'
            }
          end

          it 'the records are returned in ascending order' do
            expect(records_count).to be(4)

            expect(records.first['reviewed_at']).to be < records.second['reviewed_at']
          end
        end

        context 'when direction is `descending`' do
          let(:sorting_params) do
            {
              'sort_direction' => 'descending',
              'sort_by' => 'reviewed_at'
            }
          end

          it 'the records are returned in ascending order' do
            expect(records.first['reviewed_at']).to be_nil
            expect(records.third['reviewed_at']).to be > records.fourth['reviewed_at']
          end
        end
      end
    end
  end
end
