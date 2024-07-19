module Datastore
  module Entities
    module V1
      class ChangeInFinancialCircumstancesApplication < CrimeApplication
        expose :pre_cifc_reference_number
        expose :pre_cifc_maat_id
        expose :pre_cifc_usn
      end
    end
  end
end
