module Datastore
  module Entities
    module V1
      class PostSubmissionEvidenceApplication < Grape::Entity
        expose :id
        expose :schema_version
        expose :reference
        expose :application_type
        expose :submitted_at
        expose :provider_details
        expose :client_details
        expose :status
        expose :parent_id
        expose :created_at
        expose :supporting_evidence
        expose :work_stream
        expose :returned_at, expose_nil: false
        expose :notes

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

        def provider_details
          submitted_value('provider_details')
        end

        def client_details
          submitted_value('client_details')
        end

        def notes
          submitted_value('notes')
        end

        def parent_id
          submitted_value('parent_id')
        end

        # created_at is the date when the application was started on crime apply
        # and therefore we take the value from the application json rather than the table
        def created_at
          submitted_value('created_at')
        end

        def supporting_evidence
          submitted_value('supporting_evidence') || []
        end

        def submitted_value(name)
          object.submitted_application&.dig(name)
        end
      end
    end
  end
end
