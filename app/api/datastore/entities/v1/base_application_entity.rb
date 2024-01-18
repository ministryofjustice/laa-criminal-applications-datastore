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

        def submitted_value(name)
          object.submitted_application&.dig(name)
        end

        def parent_id
          submitted_value('parent_id')
        end

        # created_at is the date when the application was started on crime apply
        # and therefore we take the value from the application json rather than the table
        def created_at
          submitted_value('created_at')
        end
      end
    end
  end
end
