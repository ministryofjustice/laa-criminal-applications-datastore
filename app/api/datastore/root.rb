require 'grape-swagger'

module Datastore
  class Root < Base
    format :json
    prefix :api

    # JWT auth middleware from `moj-simple-jwt-auth` gem
    auth :jwt
    use SimpleJwtAuth::Middleware::Grape::Authorisation

    namespace :maat do
      mount V1::MAAT::Applications
    end

    mount V1::Applications
    mount V1::Documents
    mount V1::Searching
    mount V1::Reviewing
    mount V1::Healthcheck

    add_swagger_documentation(
      info: { title: 'Criminal Applications Datastore - v1' },
      api_version: 'v1',
      hide_documentation_path: true,
      mount_path: '/documentation',
    )

    desc 'Catch-all route.'
    route_setting :authorised_consumers, %w[*]

    route :any, '*path' do
      error!({ status: 404, error: 'Not found' }, 404)
    end
  end
end
