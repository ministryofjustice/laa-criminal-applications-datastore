module Datastore
  module Entities
    module V1
      module MAAT
        class ClientDetails < Grape::Entity
          self.hash_access = :to_s

          expose :applicant, using: Applicant
          expose :partner, using: Partner, expose_nil: false
        end
      end
    end
  end
end
