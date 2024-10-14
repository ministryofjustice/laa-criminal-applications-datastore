module Datastore
  module Entities
    module V1
      module MAAT
        class PropertyOwner < Grape::Entity
          include Transformer::MAAT

          self.hash_access = :to_s

          expose :name, expose_nil: false
          expose :relationship, expose_nil: false
          expose :other_relationship, expose_nil: false
          expose :percentage_owned, expose_nil: false

          def name
            transform!('name', rule: 'property_owner')
          end

          def other_relationship
            transform!('other_relationship', rule: 'property_owner')
          end
        end
      end
    end
  end
end
