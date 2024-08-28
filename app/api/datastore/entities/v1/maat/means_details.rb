module Datastore
  module Entities
    module V1
      module MAAT
        class MeansDetails < Grape::Entity
          self.hash_access = :to_s

          expose :income_details, using: IncomeDetails, expose_nil: false
          expose :outgoings_details, using: OutgoingsDetails, expose_nil: false
          expose :capital_details, using: CapitalDetails, expose_nil: false

          private

          def income_details
            if object['capital_details'].present?
              object['income_details'].merge!('capital_attributes' => capital_attributes)
            else
              object['income_details']
            end
          end

          def capital_attributes
            {
              'trust_fund_yearly_dividend' => object['capital_details']['trust_fund_yearly_dividend'],
              'partner_trust_fund_yearly_dividend' => object['capital_details']['partner_trust_fund_yearly_dividend']
            }
          end
        end
      end
    end
  end
end
