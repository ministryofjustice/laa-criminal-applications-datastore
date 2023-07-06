module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          expose :declaration_signed_at

          private

          def case_details
            super.except('offences', 'codefendants')
          end

          def declaration_signed_at
            submitted_value('submitted_at')
          end
        end
      end
    end
  end
end
