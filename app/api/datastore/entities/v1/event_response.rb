module Datastore
  module Entities
    module V1
      class EventResponse < Grape::Entity
        expose :event_id
        expose :event_type
        expose :timestamp
      end
    end
  end
end
