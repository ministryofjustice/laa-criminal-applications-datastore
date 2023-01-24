module Datastore
  module Entities
    class CrimeApplication < Grape::Entity
      expose :application, merge: true

      expose :status
      expose :return_details, using: ReturnDetails, expose_nil: false
    end
  end
end
