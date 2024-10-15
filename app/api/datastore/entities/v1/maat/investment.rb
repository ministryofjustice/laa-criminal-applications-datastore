module Datastore
  module Entities
    module V1
      module MAAT
        class Investment < Grape::Entity
          include Transformer::MAAT

          self.hash_access = :to_s

          expose :investment_type, expose_nil: false
          expose :description, expose_nil: false
          expose :value, expose_nil: false
          expose :ownership_type, expose_nil: false

          def description
            transform!('description', rule: 'investment')
          end
        end
      end
    end
  end
end
