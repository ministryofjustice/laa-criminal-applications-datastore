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

          def properties
            if object['properties'].present? && object['properties'].respond_to?(:each)
              object['properties'].each do |property|
                property['property_owners'].each do |property_owner|
                  ::Transformers::MAAT.chop!(property_owner, ::Transformers::MAAT::PROPERTY_OWNER_RULES)
                end

                ::Transformers::MAAT.chop!(property['address'], ::Transformers::MAAT::ADDRESS_RULES)
              end
            end

            object
          end
        end
      end
    end
  end
end
