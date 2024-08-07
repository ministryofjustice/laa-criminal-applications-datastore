module Datastore
  module Entities
    module V1
      module MAAT
        class IncomeDetails < Grape::Entity
          self.hash_access = :to_s

          expose :income_payments, using: Payment, expose_nil: false
          expose :income_benefits, using: Payment, expose_nil: false
          expose :dependants, expose_nil: false
          expose :employment_type
          expose :employment_income_payments, expose_nil: false
          expose :manage_without_income, expose_nil: false
          expose :manage_other_details, expose_nil: false

          # eForms collects student_loan_grant, board_from_family, rent and financial_support_with_access
          # as separate items while MAAT has only one 'other income' field.
          # Therefore annualized sum of all below income payments is treated as 'other income' in MAAT
          OTHER_INCOME_PAYMENT_TYPES = %w[
            student_loan_grant
            board_from_family
            rent
            financial_support_with_access
            other
          ].freeze

          # eForms collects ‘Contribution-based Job Seekers Allowance(jsa)’ and ‘Other Benefits’
          # as two separate items while MAAT has only one 'other benefits' field.
          # Therefore annualized sum of all below income benefits is treated as 'other benefit' in MAAT
          OTHER_INCOME_BENEFIT_TYPES = %w[
            jsa
            other
          ].freeze

          private

          def income_payments
            Utils::OtherPaymentCalculator.new(
              payments: object['income_payments'],
              payment_types: OTHER_INCOME_PAYMENT_TYPES,
              type: 'income_payments'
            ).call
          end

          def income_benefits
            Utils::OtherPaymentCalculator.new(
              payments: object['income_benefits'],
              payment_types: OTHER_INCOME_BENEFIT_TYPES,
              type: 'income_benefits'
            ).call
          end
        end
      end
    end
  end
end
