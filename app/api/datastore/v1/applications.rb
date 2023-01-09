module Datastore
  module V1
    class Applications < Base
      rescue_from Dynamoid::Errors::RecordNotFound do
        error!({ status: 404, error: 'Record not found' }, 404)
      end

      rescue_from Dynamoid::Errors::MissingRangeKey do
        error!({ status: 500, error: 'Missing range key' }, 500)
      end

      rescue_from Dynamoid::Errors::RecordNotUnique do
        error!({ status: 400, error: 'Record not unique' }, 400)
      end

      version 'v1', using: :path

      resource :applications do
        desc 'Return applications with optional pagination.'
        params do
          optional :status, type: String, default: 'submitted',
                   desc: 'The status of the application.'
          optional :limit, type: Integer,
                   values: 1..200, default: 20,
                   desc: 'Used to limit the results when paginating.'
          optional :sort, type: String,
                   values: Operations::Dynamodb::ListApplications::INDEX_DIRECTIONS,
                   default: Operations::Dynamodb::ListApplications::SCAN_DIRECTION_BACKWARD,
                   desc: 'Used to sort by submitted_at (asc or desc).'
          optional :page_token, type: String,
                   desc: 'Used to request a page when paginating.'
        end
        get do
          Operations::Dynamodb::ListApplications.new(
            status: params[:status], **params
          ).call
        end

        desc 'Create an application.'
        params do
          requires :application, type: JSON, desc: 'Application JSON payload.'
        end
        post do
          Operations::Dynamodb::CreateApplication.new(
            payload: params[:application]
          ).call
        end

        desc 'Return an application by ID.'
        params do
          requires :id, type: String, desc: 'Application UUID.'
        end
        route_param :id do
          get do
            Operations::Dynamodb::GetApplication.new(
              params[:id]
            ).call
          end
        end

        desc 'Update an application status by ID.'
        params do
          requires :id, type: String, desc: 'Application UUID.'
          requires :status, type: String, desc: 'Application status.'
        end
        route_param :id do
          put do
            Operations::Dynamodb::UpdateApplication.new(
              params[:id],
              payload: { status: params[:status] }
            ).call
          end
        end

        desc 'Delete an application by ID.'
        params do
          requires :id, type: String, desc: 'Application UUID.'
        end
        route_param :id do
          delete do
            Operations::Dynamodb::DeleteApplication.new(
              params[:id]
            ).call
          end
        end
      end
    end
  end
end
