module Datastore
  module Entities
    module V1
      module MAAT
        OTHER_INCOME_PAYMENTS = %w[
          interest_investment
          student_loan_grant
          board_from_family
          rent
          financial_support_with_access
          from_friends_relatives
        ].freeze

        class IncomeDetails < Grape::Entity
          self.hash_access = :to_s

          expose :income_payments, using: Payment, expose_nil: false
          expose :income_benefits, using: Payment, expose_nil: false
          expose :dependants, expose_nil: false
          expose :employment_type
          expose :employment_income_payments, expose_nil: false
          expose :manage_without_income, expose_nil: false
          expose :manage_other_details, expose_nil: false

          def income_payments
            update_or_create_other_income_payment if total_other_income_payment.positive?
            object['income_payments'].reject { |p| p['payment_type'] == 'employment' }
          end

          private

          def other_income_payment?
            object['income_payments'].any? { |income_payment| income_payment['payment_type'] == 'other' }
          end

          def update_or_create_other_income_payment
            other_income_payment? ? update_other_income_payment : create_other_income_payment
          end

          def create_other_income_payment
            object['income_payments'].push(
              {
                'payment_type' => 'other',
                'amount' => total_other_income_payment,
                'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
                'ownership_type' => 'applicant', # TODO: : Fix ownership
                'metadata' => {
                  'details' => 'Details of the other payment'
                }
              }
            )
          end

          def update_other_income_payment
            object['income_payments'].map do |payment|
              next unless payment['payment_type'] == 'other'

              annual_other_amount = annualized_amount(payment['amount'], payment['frequency'])
              payment['amount'] = annual_other_amount + total_other_income_payment
              payment['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
            end
          end

          def total_other_income_payment
            other_amount = 0
            object['income_payments'].each do |payment|
              if OTHER_INCOME_PAYMENTS.include? payment['payment_type']
                other_amount += annualized_amount(payment['amount'], payment['frequency'])
              end
            end
            other_amount
          end

          def annualized_amount(amount, frequency)
            Utils::AnnualizedAmountCalculator.annualized_amount(amount:, frequency:)
          end
        end
      end
    end
  end
end
