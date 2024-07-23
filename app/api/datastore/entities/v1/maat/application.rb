module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          unexpose(
            :created_at,
            :parent_id,
            :work_stream,
            :reviewed_at,
            :status
          )

          expose :case_details, using: CaseDetails
          expose :client_details, using: ClientDetails
          expose :date_stamp
          expose :ioj_bypass
          expose :means_passport
          expose :provider_details
          expose :submitted_at, as: :declaration_signed_at
          expose :means_details, using: MeansDetails

          private

          def ioj_bypass
            interests_of_justice.blank?
          end
        end
      end
    end
  end
end
