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

          private

          # TODO: : Need to confirm with MAAT team if they require the following income_payment objects
          # in response once annualized
          # - student_loan_grant
          # - board_from_family
          # - rent
          # - financial_support_with_access
          def income_payments
            Utils::MAAT::OtherIncomePaymentCalculator.new(
              payments: object['income_payments'],
            ).call
          end

          # TODO: : Need to confirm with MAAT team if they require the following income_benefit objects
          # in response once annualized
          # - jsa
          def income_benefits
            ::Utils::MAAT::OtherIncomeBenefitCalculator.new(
              payments: object['income_benefits'],
            ).call
          end
        end
      end
    end
  end
end
