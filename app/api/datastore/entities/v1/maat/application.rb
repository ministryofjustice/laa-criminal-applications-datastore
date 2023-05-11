module Datastore
  module Entities
    module V1
      module MAAT
        class Application < Grape::Entity
          expose :id
          expose :schema_version
          expose :reference
          expose :submitted_at, format_with: :iso8601
          expose :date_stamp
          expose :client_details
          expose :provider_details
          expose :case_details
          expose :interests_of_justice

          private

          def client_details
            submitted_value('client_details')
          end

          def schema_version
            1.0
          end

          def date_stamp
            submitted_value('date_stamp')
          end

          def provider_details
            submitted_value('provider_details')
          end

          def case_details
            case_details = submitted_value('case_details')
            case_details['offence_class'] = object.offence_class
            case_details.except!('offences', 'codefendants')
            case_details
          end

          def interests_of_justice
            submitted_value('interests_of_justice')
          end

          def reference
            submitted_value('reference').to_i
          end

          def submitted_value(name)
            object.submitted_application&.dig(name)
          end
        end
      end
    end
  end
end
