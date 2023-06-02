module Datastore
  module Entities
    module V1
      class PrunedApplication < CrimeApplication
        unexpose :provider_details,
                 :case_details,
                 :interests_of_justice,
                 :return_details,
                 :date_stamp,
                 :ioj_passport,
                 :means_passport

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
