module Datastore
  module Entities
    module V1
      class CrimeApplication < BaseApplicationEntity
        expose :status
        expose :parent_id
        expose :created_at

        expose :means_details
        expose :supporting_evidence
        expose :work_stream

        expose :returned_at, expose_nil: false
        expose :return_details, expose_nil: false

        private

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

        def means_details
          submitted_value('means_details') || {}
        end
      end
    end
  end
end
