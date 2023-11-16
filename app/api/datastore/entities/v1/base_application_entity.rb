module Datastore
  module Entities
    module V1
      class BaseApplicationEntity < Grape::Entity
        expose :id
        expose :schema_version
        expose :reference
        expose :application_type
        expose :submitted_at
        expose :date_stamp

        expose :ioj_passport
        expose :means_passport

        expose :provider_details
        expose :client_details
        expose :case_details
        expose :interests_of_justice

        private

        def id
          submitted_value('id')
        end

        def schema_version
          submitted_value('schema_version')
        end

        def reference
          submitted_value('reference')
        end

        def application_type
          submitted_value('application_type')
        end

        def date_stamp
          submitted_value('date_stamp')
        end

        def ioj_passport
          submitted_value('ioj_passport')
        end

        def means_passport
          submitted_value('means_passport')
        end

        def provider_details
          submitted_value('provider_details')
        end

        def client_details
          submitted_value('client_details')
        end

        def case_details
          case_details = submitted_value('case_details') || {}
          case_details['offence_class'] = object.offence_class
          case_details
        end

        def interests_of_justice
          submitted_value('interests_of_justice')
        end

        def submitted_value(name)
          object.submitted_application&.dig(name)
        end
      end
    end
  end
end
