module Datastore
  module Entities
    module V1
      module MAAT
        class CapitalDetails < Grape::Entity
          self.hash_access = :to_s

          expose :premium_bonds_total_value
          expose :trust_fund_amount_held
          expose :trust_fund_yearly_dividend
          expose :partner_trust_fund_amount_held
          expose :partner_trust_fund_yearly_dividend
          expose :savings, expose_nil: false
          expose :national_savings_certificates, expose_nil: false
          expose :investments, expose_nil: false
          expose :properties, using: Property, expose_nil: false
        end
      end
    end
  end
end
