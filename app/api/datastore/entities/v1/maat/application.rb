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

          expose :case_details
          expose :client_details
          expose :date_stamp
          expose :ioj_bypass
          expose :means_passport
          expose :provider_details
          expose :submitted_at, as: :declaration_signed_at
          expose :means_details do
            expose :income_details, using: IncomeDetails
            expose :outgoings_details
            expose :capital_details
          end

          private

          PAYMENT_TYPES_WITH_DETAILS = %w[
            income_payments
            income_benefits
          ].freeze

          def client_details
            super['applicant']['benefit_type'] = nil if super.dig('applicant', 'benefit_type') == 'none'
            super['applicant'].except!('relationship_to_owner_of_usual_home_address', 'relationship_status',
                                       'relationship_to_partner', 'separation_date', 'benefit_check_result',
                                       'confirm_details', 'confirm_dwp_result', 'has_benefit_evidence', 'has_nino',
                                       'will_enter_nino', 'benefit_check_status')

            super
          end

          def case_details
            super.slice(*%w[
                          urn
                          case_type
                          appeal_maat_id
                          appeal_lodged_date
                          appeal_with_changes_details
                          offence_class
                          hearing_court_name
                          hearing_date
                        ])
          end

          def income_details
            means_details.fetch('income_details', nil)
          end

          def outgoings_details
            means_details.fetch('outgoings_details', nil)&.slice('outgoings')
          end

          def capital_details
            means_details.fetch('capital_details', nil)&.slice(
              'premium_bonds_total_value',
              'trust_fund_amount_held',
              'savings',
              'national_savings_certificates',
              'investments',
              'properties'
            )
          end

          def ioj_bypass
            interests_of_justice.blank?
          end
        end
      end
    end
  end
end
