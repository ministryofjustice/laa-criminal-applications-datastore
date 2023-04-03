module Datastore
  module Entities
    class MaatApplication < Grape::Entity
      expose :reference
      expose :applicant

      private

      def applicant
        object.application&.dig('client_details', 'applicant')
      end

      def reference
        object.application&.dig('reference').to_i
      end
    end
  end
end
