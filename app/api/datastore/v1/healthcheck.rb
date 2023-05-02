module Datastore
  module V1
    class Healthcheck < Base
      version 'v1', using: :path

      resource :health do
        desc 'Performs a basic health check.'
        route_setting :authorised_consumers, %w[*]
        get do
          result = Status::Healthcheck.call

          status  result.status
          present result, with: Datastore::Entities::V1::Healthcheck
        end
      end
    end
  end
end
