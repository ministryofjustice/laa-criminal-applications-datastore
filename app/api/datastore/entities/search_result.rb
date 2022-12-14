module Datastore
  module Entities
    class SearchResult < Grape::Entity
      expose :id, as: :resource_id
    end
  end
end
