module Datastore
  module Entities
    module V1
      module MAAT
        class Property < Grape::Entity
          include Transformer::MAAT

          self.hash_access = :to_s

          expose :property_type, expose_nil: false
          expose :house_type, expose_nil: false
          expose :other_house_type, expose_nil: false
          expose :size_in_acres, expose_nil: false
          expose :usage, expose_nil: false
          expose :bedrooms, expose_nil: false
          expose :value, expose_nil: false
          expose :outstanding_mortgage, expose_nil: false
          expose :percentage_applicant_owned, expose_nil: false
          expose :percentage_partner_owned, expose_nil: false
          expose :is_home_address, expose_nil: false
          expose :has_other_owners, expose_nil: false
          expose :address, expose_nil: false
          expose :property_owners, using: PropertyOwner, expose_nil: false

          def address
            transform!('address', rule: 'property')
          end
        end
      end
    end
  end
end
