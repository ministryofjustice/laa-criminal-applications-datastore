module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          expose :submitted_at, as: :declaration_signed_at

          private

          def case_details
            super.except('offences', 'codefendants')
          end
        end
      end
    end
  end
end
