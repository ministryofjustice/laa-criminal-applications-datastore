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

          OTHER_INCOME_PAYMENTS = %w[
            student_loan_grant
            board_from_family
            rent
            financial_support_with_access
            other
          ].freeze

          OTHER_INCOME_BENEFITS = %w[
            jsa
            other
          ].freeze

          private

          def income_payments
            Utils::OtherPaymentCalculator.new(
              payments: object['income_payments'],
              other_payment_types: OTHER_INCOME_PAYMENTS,
              type: 'income_payments'
            ).call
          end

          def income_benefits
            Utils::OtherPaymentCalculator.new(
              payments: object['income_benefits'],
              other_payment_types: OTHER_INCOME_BENEFITS,
              type: 'income_benefits'
            ).call
          end
        end
      end
    end
  end
end
