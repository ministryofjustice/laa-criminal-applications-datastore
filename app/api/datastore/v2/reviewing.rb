module Datastore
  module V2
    class Reviewing < Base
      version 'v2', using: :path

      resource :applications do
        desc 'Return an application to provider.'
        params do
          requires :application_id, type: String, desc: 'Crime Application UUID'
          requires :return_details, type: JSON do
            requires :reason, type: String, values: Types::RETURN_REASONS
            requires :details, type: String, desc: 'Detailed reason for return'
          end
        end

        route_param :application_id do
          resource :return do
            put do
              return_params = declared(params).symbolize_keys
              app = Operations::ReturnApplication.new(**return_params).call
              present app, with: Datastore::Entities::CrimeApplication
            end
          end
        end

        desc 'Mark an application as complete.'
        params do
          requires :application_id, type: String, desc: 'Crime Application UUID'
        end

        route_param :application_id do
          resource :complete do
            put do
              complete_params = declared(params).symbolize_keys
              app = Operations::CompleteApplication.new(**complete_params).call
              present app, with: Datastore::Entities::CrimeApplication
            end
          end
        end
      end
    end
  end
end
