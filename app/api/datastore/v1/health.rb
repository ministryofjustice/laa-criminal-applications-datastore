module Datastore
  module V1
    class Health < Base
      version 'v1', using: :path

      get :health do
        result = Status::Healthcheck.call

        status result.status
        Datastore::Entities::Healthcheck.represent(result)
      end
    end
  end
end
