module Datastore
  module Entities
    module V1
      module MAAT
        class Partner < Grape::Entity
          self.hash_access = :to_s

          expose :first_name
          expose :last_name
          expose :other_names
          expose :date_of_birth
          expose :nino
          expose :last_jsa_appointment_date
          expose(:benefit_type) { |p| p['benefit_type'] unless p['benefit_type'] == 'none' }
          expose :dwp_response

          expose :involvement_in_case
          expose :conflict_of_interest
        end
      end
    end
  end
end
