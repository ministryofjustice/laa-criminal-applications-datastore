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

          def case_details
            chop!(super, Transformer::MAAT::URN_RULES)
          end

          def client_details
            client_details = super

            chop!(client_details['applicant'], Transformer::MAAT::PERSON_RULES)
            chop!(client_details['partner'], Transformer::MAAT::PERSON_RULES)
            chop!(client_details.dig('applicant', 'home_address'), Transformer::MAAT::ADDRESS_RULES)
            chop!(client_details.dig('applicant', 'correspondence_address'), Transformer::MAAT::ADDRESS_RULES)

            client_details
          end

          def provider_details
            chop!(super, Transformer::MAAT::PROVIDER_DETAILS_RULES)
          end
        end # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
