module Datastore
  module V1
    class Applications < Base
      version 'v1', using: :path

      resource :applications do
        desc 'Create an application.'
        route_setting :authorised_consumers, %w[crime-apply]
        params do
          requires :application, type: JSON, desc: 'Application JSON payload.'
        end
        post do
          Operations::CreateApplication.new(
            payload: params[:application]
          ).call
        end

        desc 'Return an application by ID.'
        route_setting :authorised_consumers, %w[crime-apply crime-review]
        params do
          requires :application_id, type: String, desc: 'Application UUID.'
        end
        route_param :application_id do
          get do
            Datastore::Entities::V1::CrimeApplication.represent(
              CrimeApplication.find(params[:application_id])
            )
          end
        end

        desc 'Return applications with pagination.'
        route_setting :authorised_consumers, %w[crime-apply]
        params do
          use :sorting
          use :pagination

          optional(
            :status,
            type: String,
            default: nil,
            desc: 'The status of the application.',
            values: Types::APPLICATION_STATUSES
          )

          optional(
            :office_code,
            type: String,
            default: nil,
            desc: 'The office account number handling the application.'
          )
        end

        get do
          collection = Operations::ListApplications.new(
            **declared(params).symbolize_keys
          ).call

          present :records, collection, with: Datastore::Entities::V1::CrimeApplication
          present :pagination, collection, with: Datastore::Entities::V1::Pagination
        end
      end
    end
  end
end
