module Datastore
  module Entities
    module V1
      module MAAT
        class MeansDetails < Grape::Entity
          self.hash_access = :to_s

          expose :income_details, using: IncomeDetails, expose_nil: false
          expose :outgoings_details, using: OutgoingsDetails, expose_nil: false
          expose :capital_details, using: CapitalDetails, expose_nil: false
        end
      end
    end
  end
end
