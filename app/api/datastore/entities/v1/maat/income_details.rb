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
            update_or_create_other_income_payment('applicant') if total_other_income_payment('applicant').positive?
            update_or_create_other_income_payment('partner') if total_other_income_payment('partner').positive?
            object['income_payments'].reject { |p| p['payment_type'] == 'employment' }
          end

          private

          def other_income_payment?(ownership_type)
            object['income_payments'].any? { |income_payment| income_payment['payment_type'] == 'other' && income_payment['ownership_type'] == ownership_type }
          end

          def update_or_create_other_income_payment(ownership_type)
            other_income_payment?(ownership_type) ? update_other_income_payment(ownership_type) : create_other_income_payment(ownership_type)
          end

          def create_other_income_payment(ownership_type)
            object['income_payments'].push(
              {
                'payment_type' => 'other',
                'amount' => total_other_income_payment(ownership_type),
                'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
                'ownership_type' => ownership_type, # TODO: : Fix ownership
                'metadata' => {
                  'details' => "Details of the other #{ownership_type} payment"
                }
              }
            )
          end

          def update_other_income_payment(ownership_type)
            object['income_payments'].select { |p| p['ownership_type'] == ownership_type }.map do |payment|
              next unless payment['payment_type'] == 'other'

              annual_other_amount = annualized_amount(payment['amount'], payment['frequency'])
              payment['amount'] = annual_other_amount + total_other_income_payment(ownership_type)
              payment['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
            end
          end

          def total_other_income_payment(ownership_type)
            other_amount = 0
            object['income_payments'].select { |p| p['ownership_type'] == ownership_type }.each do |payment|
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
