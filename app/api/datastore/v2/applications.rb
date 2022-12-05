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
            CrimeApplication.find(params[:id]).application
          end
        end

        desc 'Return applications with pagination.'
        params do
          use :pagination
        end
        get do
          coll = CrimeApplication.page(params['page']).per(params['per_page'])

          RecordsPage.new(
            records: coll.pluck(:application),
            pagination: Pagination.for_collection(coll)
          )
        end
      end
    end
  end
end
