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
        params do
          use :pagination
        end
        get do
          collection = CrimeApplication.page(params['page']).per(params['per_page'])

          present :records, collection, with: Datastore::Entities::CrimeApplication
          present :pagination, collection, with: Datastore::Entities::Pagination
        end
      end
    end
  end
end
