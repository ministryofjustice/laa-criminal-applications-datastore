module Datastore
  class Root < Base
    format :json
    prefix :api

    mount V1::Health
    mount V1::Applications
    mount V2::Applications
  end
end
