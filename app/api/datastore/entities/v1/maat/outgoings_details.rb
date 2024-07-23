module Datastore
  module Entities
    module V1
      module MAAT
        class OutgoingsDetails < Grape::Entity
          self.hash_access = :to_s

          expose :outgoings, expose_nil: false
        end
      end
    end
  end
end
