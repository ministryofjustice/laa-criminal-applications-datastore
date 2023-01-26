module Datastore
  module Entities
    class Sorting < Grape::Entity
      expose :sort_by
      expose :sort_direction
    end
  end
end
