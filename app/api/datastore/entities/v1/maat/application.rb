module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          unexpose :ioj_passport,
                   :interests_of_justice

          expose :submitted_at, as: :declaration_signed_at
          expose :ioj_bypass, proc: ->(_) { interests_of_justice.empty? }

          private

          def case_details
            super.except('offences', 'codefendants')
          end
        end
      end
    end
  end
end
