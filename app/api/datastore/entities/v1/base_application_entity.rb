module Datastore
  module Entities
    module V1
      class BaseApplicationEntity < Grape::Entity
        expose :id
        expose :schema_version
        expose :reference
        expose :application_type
        expose :submitted_at
        expose :status
        expose :reviewed_at
        expose :parent_id
        expose :created_at
        expose :work_stream

        private

        def additional_information
          submitted_value('additional_information')
        end

        def application_type
          submitted_value('application_type')
        end

        def case_details
          case_details = submitted_value('case_details') || {}
          case_details['offence_class'] = object.offence_class
          case_details
        end

        def client_details
          submitted_value('client_details')
        end

        def date_stamp
          submitted_value('date_stamp')
        end

        # created_at is the date when the application was started on
        # crime apply and therefore we take the value from the application
        # json rather than the table
        def created_at
          submitted_value('created_at')
        end

        def id
          submitted_value('id')
        end

        def ioj_passport
          submitted_value('ioj_passport')
        end

        def interests_of_justice
          submitted_value('interests_of_justice')
        end

        def means_details
          submitted_value('means_details') || {}
        end

        def means_passport
          submitted_value('means_passport')
        end

        def parent_id
          submitted_value('parent_id')
        end

        def provider_details
          submitted_value('provider_details')
        end

        def reference
          submitted_value('reference')
        end

        def schema_version
          submitted_value('schema_version')
        end

        def submitted_value(name)
          object.submitted_application&.dig(name)
        end

        def supporting_evidence
          submitted_value('supporting_evidence') || []
        end
      end
    end
  end
end
