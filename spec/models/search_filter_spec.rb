require 'rails_helper'

describe SearchFilter do
  subject(:search_filter) { described_class.new(params) }

  let(:params) { {} }

  describe '#active_filters' do
    subject(:active_filters) { search_filter.active_filters }

    context 'when there are no active filters' do
      it { is_expected.to be_empty }
    end

    context 'when aplication_id_in given' do
      let(:params) { { application_id_in: [SecureRandom.uuid] } }

      it { is_expected.to include 'application_id_in' }
    end

    context 'when aplication_id_in is empty array' do
      let(:params) { { application_id_in: [] } }

      it { is_expected.to be_empty }
    end

    context 'when aplication_id_not_in given' do
      let(:params) { { application_id_not_in: [SecureRandom.uuid] } }

      it { is_expected.to include 'application_id_not_in' }
    end

    context 'when aplication_id_not_in is empty array' do
      let(:params) { { application_id_not_in: [] } }

      it { is_expected.to be_empty }
    end

    context 'when applicant_date_of_birth is blank' do
      let(:params) { { application_id_not_in: '' } }

      it { is_expected.to be_empty }
    end

    context 'when query text is provided' do
      let(:params) { { search_text: 'John Deere 6000001' } }

      it { is_expected.to include 'search_text' }
    end
  end

  context 'when a non existant filter is provided' do
    let(:params) { { case_file: '1' } }

    it 'raises an error' do
      expect { search_filter }.to raise_error ActiveModel::UnknownAttributeError
    end
  end

  describe '#filter_search_text' do
    let(:params) { { search_text: 'John' } }
    let(:sql) { search_filter.apply_to_scope(CrimeApplication.all).to_sql }

    context 'when USE_STORED_SEARCHABLE_TEXT is true' do
      before { allow(ENV).to receive(:[]).with('USE_STORED_SEARCHABLE_TEXT').and_return('true') }

      it 'queries stored_searchable_text' do
        expect(sql).to include('stored_searchable_text')
      end
    end

    context 'when USE_STORED_SEARCHABLE_TEXT is false' do
      before { allow(ENV).to receive(:[]).with('USE_STORED_SEARCHABLE_TEXT').and_return('false') }

      it 'queries the generated searchable_text column' do
        expect(sql).to include('searchable_text')
        expect(sql).not_to include('stored_searchable_text')
      end
    end
  end
end
