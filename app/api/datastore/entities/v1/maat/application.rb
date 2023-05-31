module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          private

          def case_details
            super.except('offences', 'codefendants')
          end
        end
      end
    end
  end
end
