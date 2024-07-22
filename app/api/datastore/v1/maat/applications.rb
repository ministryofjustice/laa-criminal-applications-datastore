module Datastore
  module V1
    module MAAT
      class Applications < Base
        version 'v1', using: :path

        route_setting :authorised_consumers, %w[maat-adapter maat-adapter-dev maat-adapter-uat]

        resource :applications do
          desc 'Return an application by USN.'
          params do
            requires :usn, type: Integer, desc: 'Application USN.'
          end

          route_param :usn do
            get do
              Operations::MAAT::GetApplication.new(reference: params[:usn]).call
            end
          end
        end
      end
    end
  end
end
