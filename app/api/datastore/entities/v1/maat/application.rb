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
            means_details.fetch('income_details', nil)&.slice(%w[
                                                                benefits
                                                                dependants
                                                                employment_type
                                                                employment_details
                                                                other_income
                                                              ])
          end

          def outgoings_details
            means_details.fetch('outgoings_details', nil)&.slice(%w[
                                                                   outgoings
                                                                   housing_payment_type
                                                                 ])
          end

          def ioj_bypass
            interests_of_justice.blank?
          end
        end
      end
    end
  end
end
