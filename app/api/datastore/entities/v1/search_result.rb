module Datastore
  module Entities
    module V1
      class SearchResult < Grape::Entity
        expose :id, as: :resource_id
        expose :submitted_at, format_with: :iso8601
        expose :reviewed_at, format_with: :iso8601
        expose :applicant_name
        expose :reference
        expose :status
        expose :review_status
        expose :parent_id

        private

        def applicant_name
          "#{applicant&.dig('first_name')} #{applicant&.dig('last_name')}"
        end

        def applicant
          object.application&.dig('client_details', 'applicant')
        end

        def parent_id
          object.application&.dig('parent_id')
        end

        def reference
          object.application&.dig('reference').to_i
        end
      end
    end
  end
end
