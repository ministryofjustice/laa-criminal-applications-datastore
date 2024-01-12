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

        expose :created_at

        expose :means_details
        expose :supporting_evidence

        expose :returned_at, expose_nil: false
        expose :return_details, expose_nil: false

        private

        def date_stamp
          submitted_value('date_stamp')
        end

        def ioj_passport
          submitted_value('ioj_passport')
        end

        def means_passport
          submitted_value('means_passport')
        end

        def provider_details
          submitted_value('provider_details')
        end

        def client_details
          submitted_value('client_details')
        end

        def case_details
          case_details = submitted_value('case_details') || {}
          case_details['offence_class'] = object.offence_class
          case_details
        end

        def interests_of_justice
          submitted_value('interests_of_justice')
        end
        # created_at is the date when the application was started on crime apply
        # and therefore we take the value from the application json rather than the table
        def created_at
          submitted_value('created_at')
        end

        def supporting_evidence
          submitted_value('supporting_evidence') || []
        end

        def means_details
          submitted_value('means_details') || {}
        end
      end
    end
  end
end
