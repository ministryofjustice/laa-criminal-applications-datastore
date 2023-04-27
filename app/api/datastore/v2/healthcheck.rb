module Datastore
  module V2
    class Healthcheck < Base
      version 'v2', using: :path

      resource :health do
        desc 'Performs a basic health check'
        route_setting :authorised_consumers, %w[*]
        get do
          result = Status::Healthcheck.call

          status  result.status
          present result, with: Datastore::Entities::Healthcheck
        end
      end
    end
  end
end
