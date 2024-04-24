module Datastore
  module Entities
    module V1
      class PostSubmissionEvidenceApplication < BaseApplicationEntity
        expose :supporting_evidence
        expose :evidence_details
        expose :additional_information
        expose :provider_details
        expose :client_details
        expose :created_at
      end
    end
  end
end
