module Datastore
  module Entities
    module Maat
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
          application_value('client_details')
        end

        def schema_version
          1.0
        end

        def date_stamp
          application_value('date_stamp')
        end

        def provider_details
          application_value('provider_details')
        end

        def case_details
          case_details = application_value('case_details')
          case_details['offence_class'] =
            Utils::OffenceClassCalculator.new(offences: case_details['offences']).offence_class
          case_details.except!('offences', 'codefendants')
          case_details
        end

        def interests_of_justice
          application_value('interests_of_justice')
        end

        def reference
          application_value('reference').to_i
        end

        def application_value(name)
          object.application&.dig(name)
        end
      end
    end
  end
end
