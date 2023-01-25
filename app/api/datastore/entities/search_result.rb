module Datastore
  module Entities
    class SearchResult < Grape::Entity
      expose :id, as: :resource_id
      expose :submitted_at
      expose :reviewed_at
      expose :applicant_name
      expose :reference
      expose :status
      expose :review_status

      private

      def applicant_name
        "#{applicant&.dig('first_name')} #{applicant&.dig('last_name')}"
      end

      def applicant
        object.application&.dig('client_details', 'applicant')
      end

      def reference
        object.application&.dig('reference').to_i
      end
    end
  end
end
