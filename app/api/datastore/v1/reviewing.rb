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
            route_setting :authorised_consumers, (
              %w[crime-review].tap do |consumers|
                # In non-prod envs, we also let `crime-apply` issue returns (developer tools)
                consumers.append('crime-apply') unless Rails.env.production?
              end
            )
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
          optional :decisions, type: [JSON] do
            optional :reference, type: Integer
            optional :maat_id, type: Integer
            optional :case_id, type: String
            requires :interests_of_justice, type: JSON
            optional :means, type: JSON
            requires :funding_decision, type: String
            optional :comment, type: String
            optional :court_type, type: String
            optional :overall_result, type: String
          end
        end

        route_param :application_id do
          resource :complete do
            route_setting :authorised_consumers, %w[crime-review]
            put do
              complete_params = declared(params).symbolize_keys

              Datastore::Entities::V1::CrimeApplication.represent(
                Operations::CompleteApplication.new(**complete_params).call
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
