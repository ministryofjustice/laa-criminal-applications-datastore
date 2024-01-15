module Datastore
  module Entities
    module V1
      class PostSubmissionEvidenceApplication < CrimeApplication
        unexpose :returned_at,
                 :return_details,
                 :means_details,
                 :date_stamp,
                 :ioj_passport,
                 :means_passport,
                 :case_details,
                 :interests_of_justice

        expose :notes

        private

        def notes
          submitted_value('notes')
        end
      end
    end
  end
end
