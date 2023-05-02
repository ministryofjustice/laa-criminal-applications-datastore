module Datastore
  module Entities
    module V1
      class ReturnDetails < Grape::Entity
        expose :reason
        expose :details
        expose :created_at, as: :returned_at
      end
    end
  end
end
