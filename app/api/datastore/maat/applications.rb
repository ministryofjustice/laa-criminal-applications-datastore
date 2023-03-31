module Datastore
  module Maat
    class Applications < Base
      version 'maat', using: :path

      resource :applications do
        desc 'Return an application by USN.'
        params do
          requires :usn, type: Integer, desc: 'Application USN.'
        end
        route_param :usn do
          get do
            app = Operations::MaatReadyApplication.new(
              **declared(params).symbolize_keys
            ).call

            present app, with: Datastore::Entities::CrimeApplication
          end
        end
      end
    end
  end
end