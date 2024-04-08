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
            expose :income_details
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

          # Maintain `nil` return value if there are no payments
          def income_details # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
            income = means_details.fetch('income_details', nil)&.slice(
              'income_payments',
              'income_benefits',
              'dependants',
              'employment_type',
              'employment_details'
            )

            income&.each do |type, list|
              next unless PAYMENT_TYPES_WITH_DETAILS.include?(type)

              list.each do |item|
                next unless item['metadata'].is_a?(Hash)
                next if item['metadata'] == {}

                item['details'] = item.dig('metadata', 'details')
              end
            end
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
