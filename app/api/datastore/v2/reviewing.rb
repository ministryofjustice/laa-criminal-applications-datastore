module Datastore
  module V2
    class Reviewing < Base
      version 'v2', using: :path

      resource :applications do
        desc 'Return an applcation.'

        params do
          requires :application_id, type: String, desc: 'Crime Application UUID'
          requires :return_details, type: JSON do
            requires :reason_type, type: String, values: Types::RETURN_REASONS
            requires :details, type: String, desc: 'Detailed reason for return'
          end
        end

        route_param :application_id do
          resource :return do
            put do
              return_params = declared(params).symbolize_keys
              Operations::ReturnApplication.new(**return_params).call
            end
          end
        end
      end
    end
  end
end
