module Datastore
  module Entities
    module V1
      module MAAT
        class Saving < Grape::Entity
          include Transformer::MAAT

          self.hash_access = :to_s

          expose :saving_type, expose_nil: false
          expose :provider_name, expose_nil: false
          expose :account_balance, expose_nil: false
          expose :sort_code, expose_nil: false
          expose :account_number, expose_nil: false
          expose :is_overdrawn, expose_nil: false
          expose :are_wages_paid_into_account, expose_nil: false
          expose :are_partners_wages_paid_into_account, expose_nil: false
          expose :ownership_type, expose_nil: false

          def provider_name
            transform!('provider_name', rule: 'saving')
          end

          def sort_code
            transform!('sort_code', rule: 'saving')
          end
        end
      end
    end
  end
end
