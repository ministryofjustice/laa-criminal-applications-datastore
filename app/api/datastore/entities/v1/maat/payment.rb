module Datastore
  module Entities
    module V1
      module MAAT
        class Payment < Grape::Entity
          self.hash_access = :to_s

          expose :amount
          expose :frequency
          expose :metadata
          expose :payment_type
          expose :ownership_type
          expose :metadata_details, as: :details, if: ->(instance) { instance.dig('metadata', 'details') }

          def metadata_details
            object['details'] || object.dig('metadata', 'details')
          end
        end
      end
    end
  end
end
