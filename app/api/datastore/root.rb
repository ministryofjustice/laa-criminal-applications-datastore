module Datastore
  class Root < Base
    format :json
    prefix :api

    # JWT auth middleware from `moj-simple-jwt-auth` gem
    auth :jwt

    mount V2::Applications
    mount V2::Searches
    mount V2::Reviewing
    mount Maat::Applications
  end
end
