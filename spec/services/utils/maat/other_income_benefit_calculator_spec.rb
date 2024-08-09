require 'rails_helper'

# rubocop:disable RSpec/ExampleLength Metrics/AbcSize
describe Utils::MAAT::OtherIncomeBenefitCalculator do
  subject { described_class.new(payments:) }

  context 'when `income_benefits` are present with `other` payment_type' do
    let(:payments) do
      [
        {
          'payment_type' => 'child',
          'amount' => 2_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'working_or_child_tax_credit',
          'amount' => 1_000,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'jsa',
          'amount' => 15_00,
          'frequency' => 'fortnight',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'jsa',
          'amount' => 900,
          'frequency' => 'month',
          'ownership_type' => 'partner',
          'metadata' => {}
        },
        {
          'payment_type' => 'other',
          'amount' => 800,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => 'Details of the other applicant benefit'
          }
        }
      ]
    end

    it 'returns annualized `other benefits` for both applicant and partner' do
      expect(subject.call).to contain_exactly(
        {
          'payment_type' => 'child',
          'amount' => 2_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'working_or_child_tax_credit',
          'amount' => 1_000,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'other',
          'amount' => 49_400, # other(800 * 13) + jsa(15_00 * 26)
          'frequency' => 'annual',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => <<~HEREDOC
              Details of the other applicant benefit

              applicant: jsa:1500:fortnight, other:800:four_weeks
            HEREDOC
          }
        },
        {
          'payment_type' => 'other',
          'amount' => 10_800, # jsa(900 * 12)
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => 'partner: jsa:900:month'
          }
        }
      )
    end
  end

  context 'when `income_benefits` are present without `other` payment_type' do
    let(:payments) do
      [
        {
          'payment_type' => 'child',
          'amount' => 2_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'working_or_child_tax_credit',
          'amount' => 1_000,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'jsa',
          'amount' => 15_00,
          'frequency' => 'fortnight',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'jsa',
          'amount' => 900,
          'frequency' => 'month',
          'ownership_type' => 'partner',
          'metadata' => {}
        },
      ]
    end

    it 'creates `other` payment_type and returns annualized amount for both applicant and partner' do
      expect(subject.call).to contain_exactly(
        {
          'payment_type' => 'child',
          'amount' => 2_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'working_or_child_tax_credit',
          'amount' => 1_000,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'other',
          'amount' => 39_000, # jsa(15_00 * 26)
          'frequency' => 'annual',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => 'applicant: jsa:1500:fortnight'
          }
        },
        {
          'payment_type' => 'other',
          'amount' => 10_800, # jsa(900 * 12)
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => 'partner: jsa:900:month'
          }
        }
      )
    end
  end

  context 'when `income_benefits` are missing' do
    let(:payments) { [] }

    it 'returns empty array' do
      expect(subject.call).to be_empty
    end
  end
end
# rubocop:enable RSpec/ExampleLength Metrics/AbcSize
