module Datastore
  module Entities
    module V1
      module MAAT
        class Application < BaseApplicationEntity
          include Transformer::MAAT

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
            transform!(super, rule: 'case_details')
          end

          def client_details
            client_details = super
            applicant = client_details['applicant']
            applicant_rule = %w[client_details applicant]

            transform!(client_details['partner'], rule: %w[client_details partner])

            transform!(applicant, rule: applicant_rule)
            transform!(applicant['home_address'], rule: [*applicant_rule, 'home_address'])
            transform!(applicant['correspondence_address'], rule: [*applicant_rule, 'correspondence_address'])

            client_details
          end

          def provider_details
            transform!(super, rule: 'provider_details')
          end
        end # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
