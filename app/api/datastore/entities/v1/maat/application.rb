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
          end

          private

          ARRAYS_WITH_DETAILS = %w[
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

          # rubocop:disable Lint/RedundantSplatExpansion
          def income_details
            income = means_details.fetch('income_details', nil)&.slice(*%w[
                                                                         income_payments
                                                                         income_benefits
                                                                         dependants
                                                                         employment_type
                                                                         employment_details
                                                                       ])

            extract_details(income)
            income
          end

          def outgoings_details
            means_details.fetch('outgoings_details', nil)&.slice(*%w[
                                                                   outgoings
                                                                 ])
          end
          # rubocop:enable Lint/RedundantSplatExpansion

          def ioj_bypass
            interests_of_justice.blank?
          end

          def extract_details(section) # rubocop:disable Metrics/MethodLength
            section.map do |element|
              if ARRAYS_WITH_DETAILS.include?(element.first)
                new_element = [element.first]

                element.last.map do |payment|
                  payment['details'] = payment.dig('metadata', 'details') unless payment['metadata'] == {}
                  payment.delete('metadata')
                  payment
                end

                new_element << element.last
              else
                element
              end
            end
          end
        end
      end
    end
  end
end
