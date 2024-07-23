module Datastore
  module Entities
    module V1
      module MAAT
        class Applicant < Grape::Entity
          self.hash_access = :to_s

          expose :first_name
          expose :last_name
          expose :other_names
          expose :date_of_birth
          expose :nino
          expose :last_jsa_appointment_date
          expose(:benefit_type) { |p| p['benefit_type'] unless p['benefit_type'] == 'none' }

          expose :telephone_number
          expose :correspondence_address_type
          expose :residence_type
          expose :home_address
          expose :correspondence_address
          expose :has_partner
        end
      end
    end
  end
end
