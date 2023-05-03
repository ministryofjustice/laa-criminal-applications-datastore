module Datastore
  module V1
    class Reviewing < Base
      version 'v1', using: :path

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
            route_setting :authorised_consumers, %w[crime-apply crime-review]
            put do
              return_params = declared(params).symbolize_keys
              app = Operations::ReturnApplication.new(**return_params).call
              present app, with: Datastore::Entities::V1::CrimeApplication
            end
          end
        end

        desc 'Mark an application as complete.'
        params do
          requires :application_id, type: String, desc: 'Crime Application UUID'
        end

        route_param :application_id do
          resource :complete do
            route_setting :authorised_consumers, %w[crime-review]
            put do
              Datastore::Entities::V1::CrimeApplication.represent(
                Operations::CompleteApplication.new(application_id: params[:application_id]).call
              )
            end
          end
        end

        desc 'Mark an application as ready for assessment.'
        params do
          requires :application_id, type: String, desc: 'Crime Application UUID'
        end

        route_param :application_id do
          resource :mark_as_ready do
            route_setting :authorised_consumers, %w[crime-review]
            put do
              Datastore::Entities::V1::CrimeApplication.represent(
                Operations::MarkAsReadyApplication.new(application_id: params[:application_id]).call
              )
            end
          end
        end
      end
    end
  end
end
