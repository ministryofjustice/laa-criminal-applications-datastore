module Datastore
  class Root < Base
    format :json
    prefix :api

    mount V1::Health
    mount V1::Applications

    mount V2::Health
    mount V2::Applications
    mount V2::Searches
  end
end
