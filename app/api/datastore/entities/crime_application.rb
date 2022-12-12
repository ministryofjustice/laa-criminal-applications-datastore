module Datastore
  module Entities
    class CrimeApplication < Grape::Entity
      expose :application, merge: true

      expose :status
    end
  end
end
