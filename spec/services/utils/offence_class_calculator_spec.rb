require 'rails_helper'

describe Utils::OffenceClassCalculator do
  subject { described_class.new(offences:) }

  let(:attempted_robbery_offence) do
    {
      'name' => 'Attempt robbery',
        'offence_class' => 'C',
        'dates' => [
          { 'date_from' => '2020-05-11', 'date_to' => '2020-05-12' },
          { 'date_from' => '2020-08-11', 'date_to' => nil }
        ]
    }
  end

  describe 'Overall offence class calculation' do
    context 'when calculating for an application with a multi class offence' do
      let(:offences) do
        [
          attempted_robbery_offence,
          {
            'name' => 'Fraud',
            'offence_class' => 'F/B/C',
            'dates' => [
              { 'date_from' => '2020-05-11', 'date_to' => '2020-05-12' },
              { 'date_from' => '2020-08-11', 'date_to' => nil }
            ]
          }
        ]
      end

      it 'returns an undetermined offence class' do
        expect(subject.offence_class).to be_nil
      end
    end

    context 'when calculating for an application with single class offences' do
      let(:offences) do
        [
          attempted_robbery_offence,
          {
            'name' => 'Homicide',
            'offence_class' => 'A',
            'dates' => [
              { 'date_from' => '2020-05-11', 'date_to' => '2020-05-12' },
              { 'date_from' => '2020-08-11', 'date_to' => nil }
            ]
          }
        ]
      end

      it 'returns the highest ranking offence class' do
        expect(subject.offence_class).to eq('A')
      end
    end

    context 'when calculating for an application with a manually entered offence' do
      let(:offences) do
        [
          attempted_robbery_offence,
          {
            'name' => 'Non-listed offence, manually entered',
            'offence_class' => nil,
            'dates' => [
              { 'date_from' => '2020-09-15', 'date_to' => nil }
            ]
          }
        ]
      end

      it 'returns an undetermined offence class' do
        expect(subject.offence_class).to be_nil
      end
    end
  end
end
