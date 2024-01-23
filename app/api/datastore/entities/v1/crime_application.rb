module Datastore
  module Entities
    module V1
      class CrimeApplication < BaseApplicationEntity
        expose :date_stamp

        expose :ioj_passport
        expose :means_passport

        expose :provider_details
        expose :client_details
        expose :case_details
        expose :interests_of_justice

        expose :means_details
        expose :supporting_evidence
        expose :additional_information

        expose :returned_at, expose_nil: false
        expose :return_details, expose_nil: false
      end
    end
  end
end
