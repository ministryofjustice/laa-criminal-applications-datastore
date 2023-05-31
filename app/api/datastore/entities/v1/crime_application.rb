module Datastore
  module Entities
    module V1
      class CrimeApplication < BaseApplicationEntity
        expose :status
        expose :parent_id
        expose :created_at
        expose :returned_at, expose_nil: false
        expose :ioj_passport
        expose :means_passport

        expose :return_details, using: V1::ReturnDetails, expose_nil: false

        private

        def parent_id
          submitted_value('parent_id')
        end

        # created_at is the date when the application was started on crime apply
        # and therefore we take the value from the application json rather than the table
        def created_at
          submitted_value('created_at')
        end

        def ioj_passport
          submitted_value('ioj_passport')
        end

        def means_passport
          submitted_value('means_passport')
        end
      end
    end
  end
end
