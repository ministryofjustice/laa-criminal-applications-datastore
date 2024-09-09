module Datastore
  module Entities
    module V1
      module MAAT
        class CaseDetails < Grape::Entity
          self.hash_access = :to_s

          expose :urn
          expose :case_type, expose_nil: false
          expose :appeal_maat_id
          expose :appeal_usn
          expose :appeal_lodged_date
          expose :appeal_with_changes_details
          expose :offence_class
          expose :hearing_court_name, expose_nil: false
          expose :hearing_date
        end
      end
    end
  end
end
