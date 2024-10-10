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
          expose :properties, expose_nil: false

          private

          # TODO: Consider converting `properties` into a Grape::Entity like `payment`
          def properties
            return unless object['properties'].respond_to?(:each)

            object['properties'].each do |property|
              next unless property['property_owners'].respond_to?(:each)

              property['property_owners'].each do |property_owner|
                Transformer::MAAT.chop!(property_owner, Transformer::MAAT::PROPERTY_OWNER_RULES)
              end

              Transformer::MAAT.chop!(property['address'], Transformer::MAAT::ADDRESS_RULES)
            end
          end
        end
      end
    end
  end
end
