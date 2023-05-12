module Datastore
  module Entities
    module V1
      class CrimeApplication < Grape::Entity
        expose :id
        expose :parent_id
        expose :schema_version
        expose :reference
        expose :created_at
        expose :submitted_at, format_with: :iso8601
        expose :returned_at, expose_nil: false
        expose :date_stamp
        expose :provider_details
        expose :client_details
        expose :case_details
        expose :interests_of_justice
        expose :ioj_passport
        expose :means_passport

        expose :status
        expose :return_details, using: V1::ReturnDetails, expose_nil: false

        private

        def id
          submitted_value('id')
        end

        def parent_id
          submitted_value('parent_id')
        end

        def schema_version
          submitted_value('schema_version')
        end

        def client_details
          submitted_value('client_details')
        end

        # created_at is the date when the application was started on crime apply
        # and therefore we take the value from the application json rather than the table
        def created_at
          submitted_value('created_at')
        end

        def date_stamp
          submitted_value('date_stamp')
        end

        def provider_details
          submitted_value('provider_details')
        end

        def case_details
          case_details = submitted_value('case_details') || {}
          case_details['offence_class'] = object.offence_class
          case_details
        end

        def interests_of_justice
          submitted_value('interests_of_justice')
        end

        def reference
          submitted_value('reference').to_i
        end

        def ioj_passport
          submitted_value('ioj_passport')
        end

        def means_passport
          submitted_value('means_passport')
        end

        def submitted_value(name)
          object.submitted_application&.dig(name)
        end
      end
    end
  end
end
