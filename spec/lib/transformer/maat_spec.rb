require 'rails_helper'

describe Transformer::MAAT do
  describe '.chop!' do
    subject(:result) do
      described_class.chop!(obj, criteria)
    end

    let(:obj) do
      {
        'organisation' => 'Ministry of Justice at 102 Petty France',
        'city' => 'London',
        'people' => 200,
      }
    end

    let(:criteria) { nil }

    context 'when criteria is a hash' do
      let(:criteria) do
        {
          'organisation' => 22,
        }
      end

      it 'chops hash values based on supplied criteria' do
        expect(result).to eq(
          'organisation' => 'Ministry of Justice...',
          'city' => 'London',
          'people' => 200,
        )

        expect(result['organisation'].length).to eq 22
      end
    end

    context 'when criteria is a number' do
      let(:criteria) { 5 }

      it 'chops hash values down to criteria length' do
        expect(result).to eq(
          'organisation' => 'Mi...',
          'city' => 'Lo...',
          'people' => 200,
        )

        expect(result['organisation'].length).to eq 5
      end
    end

    context 'when obj is a string' do
      let(:obj) { 'My string' }
      let(:criteria) { 5 }

      it { is_expected.to eq 'My...' }
    end

    context 'when obj is nil' do
      let(:obj) { nil }

      it { is_expected.to be_nil }
    end

    context 'with missing criteria' do
      let(:criteria) { nil }

      it { is_expected.to eq obj }
    end
  end

  describe '.truncate!' do
    it 'appends ...' do
      expect(described_class.truncate!('United Kingdom', 9)).to eq 'United...'
    end
  end
end
