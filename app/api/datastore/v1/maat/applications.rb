module Datastore
  module V1
    module MAAT
      class Applications < Base
        version 'v1', using: :path

        route_setting :authorised_consumers, %w[maat-adapter]

        resource :applications do
          desc 'Return an application by USN.'
          params do
            requires :usn, type: Integer, desc: 'Application USN.'
          end
          route_param :usn do
            get do
              Datastore::Entities::V1::MAAT::Application.represent(
                CrimeApplication.find_by!(
                  reference: params[:usn],
                  review_status: Types::ReviewApplicationStatus['ready_for_assessment']
                )
              )
            end
          end
        end
      end
    end
  end
end
