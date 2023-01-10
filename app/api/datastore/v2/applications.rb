module Datastore
  module V2
    class Applications < Base
      version 'v2', using: :path

      resource :applications do
        desc 'Create an application.'
        params do
          requires :application, type: JSON, desc: 'Application JSON payload.'
        end
        post do
          Operations::CreateApplication.new(
            payload: params[:application]
          ).call
        end

        desc 'Return an application by ID.'
        params do
          requires :id, type: String, desc: 'Application UUID.'
        end
        route_param :id do
          get do
            Datastore::Entities::CrimeApplication.represent CrimeApplication.find(params[:id])
          end
        end

        desc 'Return applications with pagination.'
        # rubocop:disable Metrics/BlockLength
        params do
          use :pagination

          optional(
            :status,
            type: String,
            default: nil,
            desc: 'The status of the application.',
            values: CrimeApplication::STATUSES
          )

          optional(
            :office_code,
            type: String,
            default: nil,
            desc: 'The office account number handling the application.'
          )

          optional(
            :sort,
            type: Symbol,
            default: :descending,
            desc: 'Sort order for the records.',
            values: %i[descending ascending]
          )

          optional(
            :order,
            type: String,
            default: nil,
            desc: 'Order records by provided attribute'
          )
        end
        # rubocop:enable Metrics/BlockLength

        get do
          collection = Operations::ListApplications.new(
            **declared(params).symbolize_keys
          ).call

          present :records, collection, with: Datastore::Entities::CrimeApplication
          present :pagination, collection, with: Datastore::Entities::Pagination
        end
      end
    end
  end
end
