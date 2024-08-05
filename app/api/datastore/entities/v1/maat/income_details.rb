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

          def income_payments
            Utils::IncomePaymentsCalculator.new(income_payments: object['income_payments']).update
          end
        end
      end
    end
  end
end
