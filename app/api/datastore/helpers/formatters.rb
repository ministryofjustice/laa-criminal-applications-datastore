module Datastore
  module Helpers
    module Formatters
      extend Grape::API::Helpers

      Grape::Entity.format_with :iso8601 do |date|
        date&.iso8601
      end
    end
  end
end
