module Datastore
  module Entities
    class CrimeApplication < Grape::Entity
      expose :application, merge: true
    end
  end
end
