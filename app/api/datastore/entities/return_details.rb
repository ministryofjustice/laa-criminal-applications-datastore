module Datastore
  module Entities
    class ReturnDetails < Grape::Entity
      expose :reason
      expose :details
      expose :created_at, as: :returned_at
    end
  end
end
