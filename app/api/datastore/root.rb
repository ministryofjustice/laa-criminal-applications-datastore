module Datastore
  class Root < Base
    format :json
    prefix :api

    # JWT auth middleware from `moj-simple-jwt-auth` gem
    auth :jwt
    use SimpleJwtAuth::Middleware::Grape::Authorisation

    mount V2::Applications
    mount V2::Searches
    mount V2::Reviewing
    mount Maat::Applications

    desc 'Catch-all route'
    route_setting :authorised_consumers, %w[*]
    route :any, '*path' do
      error!({ status: 404, error: 'Not found' }, 404)
    end
  end
end
