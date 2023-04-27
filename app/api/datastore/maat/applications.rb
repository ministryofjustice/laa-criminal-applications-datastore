module Datastore
  module Maat
    class Applications < Base
      version 'maat', using: :path

      route_setting :authorised_consumers, %w[maat-adapter]

      resource :applications do
        desc 'Return an application by USN.'
        params do
          requires :usn, type: Integer, desc: 'Application USN.'
        end
        route_param :usn do
          get do
            app = Operations::Maat::ApplicationReady.new(
              **declared(params).symbolize_keys
            ).call

            present app, with: Datastore::Entities::Maat::Application
          end
        end
      end
    end
  end
end
