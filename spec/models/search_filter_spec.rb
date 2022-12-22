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
end
