module Datastore
  module Entities
    class Healthcheck < Grape::Entity
      expose :status
      expose :error
    end
  end
end
