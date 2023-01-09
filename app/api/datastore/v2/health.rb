module Datastore
  module V2
    class Health < Base
      version 'v2', using: :path

      get :health do
        result = Status::Healthcheck.call

        status result.status
        Datastore::Entities::Healthcheck.represent(result)
      end
    end
  end
end
