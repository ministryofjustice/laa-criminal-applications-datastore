require 'rails_helper'

RSpec.describe Reporting::VolumesByOfficeReport do
  subject(:report) { described_class.new(period:, application_types:) }

  let(:period) { '2025-July' }
  let(:application_types) { %w[initial change_in_financial_circumstances] }

  describe '#date' do
    subject(:date) { report.date }

    it 'parses the period into a date in London time zone' do
      expect(date).to eq Time.new(2025, 7, 1, 0, 0, 0, '+01:00')
      expect(date.zone).to eq 'BST'
    end
  end

  describe '#range' do
    subject(:range) { report.range }

    it 'returns the full month range for the given period in correct time zone' do
      expect(range.first).to eq(Time.utc(2025, 6, 30, 23))
      expect(range.last).to eq(Time.parse('2025-07-31 22:59:59.999999999 +0000'))
    end
  end

  describe '#data' do
    subject(:data) { report.data }

    let(:relation) { instance_double(ActiveRecord::Relation) }

    before do
      allow(CrimeApplication).to receive(:where).and_return(relation)
      allow(relation).to receive_messages(group: relation, count: [{ A: 1 }])
    end

    it 'returns volumes by office for a give month' do
      expect(data).to eq [{ A: 1 }]

      expect(CrimeApplication).to have_received(:where)
        .with(submitted_at: report.range, application_type: application_types)
      expect(relation).to have_received(:group).with(:office_code)
    end
  end

  describe '#as_json()' do
    subject(:data) { report.as_json }

    it { is_expected.to eq({ data: {} }) }
  end
end
