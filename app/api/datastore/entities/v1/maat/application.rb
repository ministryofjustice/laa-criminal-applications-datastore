module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          unexpose :ioj_passport,
                   :interests_of_justice,
                   :status,
                   :parent_id,
                   :created_at,
                   :work_stream,
                   :additional_information

          expose :submitted_at, as: :declaration_signed_at
          expose :ioj_bypass, proc: ->(_) { interests_of_justice.empty? }

          expose :date_stamp
          expose :means_passport
          expose :provider_details
          expose :client_details
          expose :case_details

          private

          def case_details
            submitted_value('case_details').except(
              'offences',
              'codefendants',
              # TODO: clarify with MAAT if they need the first court hearing details
              'is_first_court_hearing',
              'first_court_hearing_name'
            )
          end
        end
      end
    end
  end
end
