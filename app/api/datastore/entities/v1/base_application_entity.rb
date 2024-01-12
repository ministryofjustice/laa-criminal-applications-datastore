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
        expose :review_status
        expose :parent_id
        expose :created_at
        expose :work_stream

        private

        def review_status
          object.review_status
        end

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
      end
    end
  end
end
