module Datastore
  module Entities
    module V1
      class Healthcheck < Grape::Entity
        expose :status
        expose :error
      end
    end
  end
end
