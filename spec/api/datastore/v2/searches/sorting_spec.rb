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

  let(:records_count) { JSON.parse(response.body).fetch('records').count }

  before do
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

    # context 'when status is `submitted`' do
    #   context 'when sorting by `submitted_at`' do
    #     context 'when direction is `ascending`' do
    #       let(:query) { '?status=submitted&sort_by=submitted_at&sort_direction=asc' }

    #       it 'the records are returned in ascending order' do
    #         expect(records.size).to be(2)

    #         expect(records.pluck('status')).to all(eq('submitted'))
    #         expect(records.first['submitted_at']).to be < records.second['submitted_at']
    #       end
    #     end

    #     context 'when direction is `descending`' do
    #       let(:query) { '?status=submitted&sort_by=submitted_at&sort_direction=desc' }

    #       it 'the records are returned in ascending order' do
    #         expect(records.size).to be(2)

    #         expect(records.pluck('status')).to all(eq('submitted'))
    #         expect(records.first['submitted_at']).to be > records.second['submitted_at']
    #       end
    #     end
    #   end
    # end

    # context 'when status is `returned`' do
    #   context 'when sorting by `submitted_at`' do
    #     context 'when direction is `ascending`' do
    #       let(:query) { '?status=returned&sort_by=submitted_at&sort_direction=asc' }

    #       it 'the records are returned in ascending order' do
    #         expect(records.size).to be(2)

    #         expect(records.pluck('status')).to all(eq('returned'))
    #         expect(records.first['submitted_at']).to be < records.second['submitted_at']
    #       end
    #     end

    #     context 'when direction is `descending`' do
    #       let(:query) { '?status=returned&sort_by=submitted_at&sort_direction=desc' }

    #       it 'the records are returned in ascending order' do
    #         expect(records.size).to be(2)

    #         expect(records.pluck('status')).to all(eq('returned'))
    #         expect(records.first['submitted_at']).to be > records.second['submitted_at']
    #       end
    #     end
    #   end

    #   context 'when sorting by `returned_at`' do
    #     context 'when direction is ascending' do
    #       let(:query) { '?status=returned&sort_by=returned_at&sort_direction=asc' }

    #       it 'the records are returned in ascending order' do
    #         expect(records.size).to be(2)

    #         expect(records.pluck('status')).to all(eq('returned'))
    #         expect(records.first['returned_at']).to be < records.second['returned_at']
    #       end
    #     end

    #     context 'when direction is descending' do
    #       let(:query) { '?status=returned&sort_by=returned_at&sort_direction=desc' }

    #       it 'the records are returned in ascending order' do
    #         expect(records.size).to be(2)

    #         expect(records.pluck('status')).to all(eq('returned'))
    #         expect(records.first['returned_at']).to be > records.second['returned_at']
    #       end
    #     end
    #   end
    # end
  end
end
