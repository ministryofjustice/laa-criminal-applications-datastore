module Datastore
  module Entities
    module V1
      class Sorting < Grape::Entity
        expose :sort_by
        expose :sort_direction
      end
    end
  end
end
