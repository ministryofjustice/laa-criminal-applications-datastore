module Datastore
  module Entities
    module V1
      module MAAT
        class IncomeDetails < Grape::Entity
          self.hash_access = :to_s

          expose :income_payments, using: Payment
          expose :income_benefits, using: Payment
          expose :dependants
          expose :employment_type
          expose :employment_income_payments, expose_nil: false

          def income_payments
            object['income_payments'].reject { |p| p['payment_type'] == 'employment' }
          end
        end
      end
    end
  end
end