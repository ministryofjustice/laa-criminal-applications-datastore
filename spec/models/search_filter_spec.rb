require 'rails_helper'

describe SearchFilter do
  subject(:search_filter) { described_class.new(params) }

  let(:params) { {} }

  describe '#active_filters' do
    subject(:active_filters) { search_filter.active_filters }

    context 'when there are no active filters' do
      it { is_expected.to be_empty }
    end

    context 'when aplication_ids are given' do
      let(:params) { { application_ids: [SecureRandom.uuid] } }

      it { is_expected.to have_key 'application_ids' }
    end

    context 'when query text is provided' do
      let(:params) { { search_text: 'John Deere 6000001' } }

      it { is_expected.to have_key 'search_text' }
    end
  end

  describe '#active?' do
    subject(:active) { search_filter.active? }

    context 'when there are no active filters' do
      it { is_expected.to be false }
    end

    context 'when there is an active filter' do
      let(:params) { { application_ids: [SecureRandom.uuid] } }

      it { is_expected.to be true }
    end
  end

  context 'when a non existant filter is provided' do
    let(:params) { { case_file: '1' } }

    it 'raises an error' do
      expect { search_filter }.to raise_error ActiveModel::UnknownAttributeError
    end
  end
end
