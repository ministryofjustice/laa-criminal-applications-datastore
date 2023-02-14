module Datastore
  class Root < Base
    format :json
    prefix :api

    # auth :jwt

    mount V2::Health
    mount V2::Applications
    mount V2::Searches
    mount V2::Reviewing
  end
end
