require 'rails_helper'

# rubocop:disable RSpec/ExampleLength Metrics/AbcSize
describe Utils::OtherPaymentCalculator do
  subject { described_class.new(payments:, payment_types:, type:) }

  context 'when `income_payments`' do
    let(:type) { 'income_payments' }
    let(:payments) do
      [
        {
          'payment_type' => 'employment',
          'amount' => 10_000,
          'frequency' => 'week',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'maintenance',
          'amount' => 3_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'student_loan_grant',
          'amount' => 1_000,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'rent',
          'amount' => 15_00,
          'frequency' => 'fortnight',
          'ownership_type' => 'partner',
          'metadata' => {}
        },
        {
          'payment_type' => 'student_loan_grant',
          'amount' => 15_000,
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {}
        },
        {
          'payment_type' => 'other',
          'amount' => 700,
          'frequency' => 'month',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => 'Details of the other partner payment'
          }
        },
        {
          'payment_type' => 'other',
          'amount' => 800,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => 'Details of the other applicant payment'
          }
        }
      ]
    end

    let(:payment_types) do
      %w[
        student_loan_grant
        rent
        other
      ]
    end

    it 'returns annualized `other income` for both applicant and partner' do
      expect(subject.call).to contain_exactly(
        {
          'payment_type' => 'maintenance',
          'amount' => 3_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'student_loan_grant',
          'amount' => 1_000,
          'frequency' => 'four_weeks',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'rent',
          'amount' => 15_00,
          'frequency' => 'fortnight',
          'ownership_type' => 'partner',
          'metadata' => {}
        },
        {
          'payment_type' => 'student_loan_grant',
          'amount' => 15_000,
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {}
        },
        {
          'payment_type' => 'other',
          'amount' => 62_400, # other(700 * 12) + rent(1500 * 26) + student_loan_grant(15000)
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => <<~HEREDOC
              Details of the other partner payment

              rent:1500:fortnight:partner, student_loan_grant:15000:annual:partner, other:700:month:partner
            HEREDOC
          },
        },
        {
          'payment_type' => 'other',
          'amount' => 22_600, # other(800 * 12) + student_loan_grant(1000 * 13)
          'frequency' => 'annual',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => <<~HEREDOC
              Details of the other applicant payment

              student_loan_grant:1000:four_weeks:applicant, other:800:month:applicant
            HEREDOC
          }
        }
      )
    end
  end

  context 'when `income_benefits`' do
    let(:type) { 'income_benefits' }
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

    let(:payment_types) do
      %w[jsa other]
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
          'amount' => 49_400, # other(800 * 13) + jsa(15_00 * 26)
          'frequency' => 'annual',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => <<~HEREDOC
              Details of the other applicant benefit

              jsa:1500:fortnight:applicant, other:800:four_weeks:applicant
            HEREDOC
          }
        },
        {
          'payment_type' => 'other',
          'amount' => 10_800, # jsa(900 * 12)
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => 'jsa:900:month:partner'
          }
        }
      )
    end
  end
end
# rubocop:enable RSpec/ExampleLength Metrics/AbcSize
