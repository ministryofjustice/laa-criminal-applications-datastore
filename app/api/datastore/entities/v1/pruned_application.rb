module Datastore
  module Entities
    module V1
      class PrunedApplication < CrimeApplication
        unexpose :provider_details,
                 :case_details,
                 :interests_of_justice,
                 :return_details,
                 :ioj_passport,
                 :means_passport,
                 :means_details,
                 :supporting_evidence,
                 :evidence_details,
                 :work_stream,
                 :additional_information

        expose :client_details do
          expose :applicant do
            expose :applicant_details, merge: true
          end
        end

        private

        def applicant_details
          return {} if client_details.nil?

          client_details['applicant'].slice('first_name', 'last_name')
        end
      end
    end
  end
end
