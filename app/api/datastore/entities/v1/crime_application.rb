module Datastore
  module Entities
    module V1
      class CrimeApplication < Grape::Entity
        expose :application, merge: true

        expose :status
        expose :return_details, using: V1::ReturnDetails, expose_nil: false
      end
    end
  end
end
