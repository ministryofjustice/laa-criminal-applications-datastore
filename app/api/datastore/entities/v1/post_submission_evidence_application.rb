module Datastore
  module Entities
    module V1
      class PostSubmissionEvidenceApplication < BaseApplicationEntity
        expose :supporting_evidence
        expose :notes
        expose :provider_details
        expose :client_details

        private

        def supporting_evidence
          submitted_value('supporting_evidence') || []
        end

        def notes
          submitted_value('notes')
        end

        def provider_details
          submitted_value('provider_details')
        end

        def client_details
          submitted_value('client_details')
        end
      end
    end
  end
end
