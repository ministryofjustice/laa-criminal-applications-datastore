require 'rails_helper'

RSpec.describe Reporting::SlipstreamAuditReport do
  subject(:report) { described_class.new(period:, **options) }

  let(:period) { '2025-May' }
  let(:options) { {} }
  let(:in_period) { Date.new(2025, 5, 15).in_time_zone('London') }
  let(:out_of_period) { Date.new(2025, 6, 1).in_time_zone('London') }

  before do
    create_outcome(business_reference: 1, status: 'confirmed', submitted_at: in_period, office_code: 'AA')
    create_outcome(business_reference: 2, status: 'withdrawn', submitted_at: in_period, office_code: 'BB')
    create_outcome(business_reference: 3, status: 'confirmed', submitted_at: out_of_period, office_code: 'CC')
  end

  def create_outcome(**attrs)
    SlipstreamAuditSelectionOutcome.create!(
      {
        crime_application_id: SecureRandom.uuid,
        application_type: 'initial',
        sample_rate: 10,
        sampled_at: attrs.fetch(:submitted_at),
        status_determined_at: attrs.fetch(:submitted_at)
      }.merge(attrs)
    )
  end

  describe '#data' do
    it 'returns confirmed outcomes submitted in the period by default' do
      expect(report.data.pluck(:reference)).to eq([1])
    end

    it 'includes the outcome and lifecycle metadata for each entry' do
      expect(report.data.first).to include(
        reference: 1,
        office_code: 'AA',
        application_type: 'initial',
        status: 'confirmed',
        sample_rate: 10
      )
    end

    context 'when a status is given' do
      let(:options) { { status: 'withdrawn' } }

      it 'returns outcomes with that status in the period' do
        expect(report.data.pluck(:reference)).to eq([2])
      end
    end
  end

  describe '#as_json' do
    it 'wraps the entries under a data key' do
      expect(report.as_json).to eq(data: report.data)
    end
  end
end
