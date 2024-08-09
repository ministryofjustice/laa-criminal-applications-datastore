require 'rails_helper'

# rubocop:disable RSpec/ExampleLength Metrics/AbcSize
describe Utils::MAAT::OtherIncomePaymentCalculator do
  subject { described_class.new(payments:) }

  context 'when `income_payments` are present with `other` payment_type' do
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
          'payment_type' => 'from_friends_relatives',
          'amount' => 1_000,
          'frequency' => 'annual',
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
          'payment_type' => 'other',
          'amount' => 62_400, # other(700 * 12) + rent(1500 * 26) + student_loan_grant(15000)
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => <<~HEREDOC
              Details of the other partner payment

              partner: rent:1500:fortnight, student_loan_grant:15000:annual, other:700:month
            HEREDOC
          },
        },
        {
          'payment_type' => 'other',
          'amount' => 23_600, # other(800 * 12) + student_loan_grant(1000 * 13) + from_friends_relatives(1000)
          'frequency' => 'annual',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => <<~HEREDOC
              Details of the other applicant payment

              applicant: student_loan_grant:1000:four_weeks, from_friends_relatives:1000:annual, other:800:month
            HEREDOC
          }
        }
      )
    end
  end

  context 'when `income_payments` are present without `other` payment_type' do
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
        }
      ]
    end

    it 'creates `other` payment_type and returns annualized amount for both applicant and partner' do
      expect(subject.call).to contain_exactly(
        {
          'payment_type' => 'maintenance',
          'amount' => 3_000,
          'frequency' => 'month',
          'ownership_type' => 'applicant',
          'metadata' => {}
        },
        {
          'payment_type' => 'other',
          'amount' => 54_000, # rent(1500 * 26) + student_loan_grant(15000)
          'frequency' => 'annual',
          'ownership_type' => 'partner',
          'metadata' => {
            'details' => 'partner: rent:1500:fortnight, student_loan_grant:15000:annual'
          },
        },
        {
          'payment_type' => 'other',
          'amount' => 13_000, # student_loan_grant(1000 * 13)
          'frequency' => 'annual',
          'ownership_type' => 'applicant',
          'metadata' => {
            'details' => 'applicant: student_loan_grant:1000:four_weeks'
          }
        }
      )
    end
  end

  context 'when `income_payments` are missing' do
    let(:payments) { [] }

    it 'returns empty array' do
      expect(subject.call).to be_empty
    end
  end
end
# rubocop:enable RSpec/ExampleLength Metrics/AbcSize
