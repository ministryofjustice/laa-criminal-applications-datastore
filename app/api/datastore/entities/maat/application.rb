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
        expose :ioj_passport

        private

        def client_details
          object.application&.dig('client_details')
        end

        def schema_version
          1.0
        end

        def date_stamp
          object.application&.dig('date_stamp')
        end

        def provider_details
          object.application&.dig('provider_details')
        end

        def case_details
          case_details = object.application&.dig('case_details')
          case_details['offence_class'] = nil
          case_details.except!('offences', 'codefendants')
          case_details
        end

        def interests_of_justice
          object.application&.dig('interests_of_justice')
        end

        def ioj_passport
          object.application&.dig('ioj_passport')
        end

        def reference
          object.application&.dig('reference').to_i
        end
      end
    end
  end
end
