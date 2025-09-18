module Datastore
  module V1
    class Applications < Base
      version 'v1', using: :path

      resource :applications do
        desc 'Create an application.'
        route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod]
        params do
          requires :application, type: JSON, desc: 'Application JSON payload.'
        end
        post do
          Operations::CreateApplication.new(
            payload: params[:application]
          ).call
        end

        desc 'Return an application by ID.'
        route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod crime-review]
        params do
          requires :application_id, type: String, desc: 'Application UUID.'
        end
        route_param :application_id do
          get do
            crime_application = CrimeApplication.find(params[:application_id])
            if crime_application.application_type == Types::ApplicationType['post_submission_evidence']
              Datastore::Entities::V1::PostSubmissionEvidenceApplication.represent(crime_application)
            elsif crime_application.application_type == Types::ApplicationType['change_in_financial_circumstances']
              Datastore::Entities::V1::ChangeInFinancialCircumstancesApplication.represent(crime_application)
            else
              Datastore::Entities::V1::CrimeApplication.represent(crime_application)
            end
          end
        end

        desc 'Return a pruned version of the applications with pagination.'
        route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod]
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
            **declared(params).symbolize_keys, consumer: current_consumer
          ).call

          present :records, collection, with: Datastore::Entities::V1::PrunedApplication
          present :pagination, collection, with: Datastore::Entities::V1::Pagination
        end

        desc 'Archive an application.'
        params do
          requires :application_id, type: String, desc: 'Application UUID.'
        end
        route_param :application_id do
          resource :archive do
            route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod]
            put do
              Operations::ArchiveApplication.new(application_id: params[:application_id]).call
            end
          end
        end

        desc 'Create a DraftCreated event for an application.'
        route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod]
        params do
          requires :entity_id, type: String, desc: 'Draft application UUID.'
          requires :entity_type, type: String, values: Types::APPLICATION_TYPES, desc: 'Draft application type.'
          requires :business_reference, type: String, desc: 'Draft application reference number.'
        end
        post 'draft_created' do
          Operations::DraftCreated.new(**declared(params).symbolize_keys).call
        end

        desc 'Create a DraftUpdated event for an application.'
        route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod]
        params do
          requires :entity_id, type: String, desc: 'Draft application UUID.'
          requires :entity_type, type: String, values: Types::APPLICATION_TYPES, desc: 'Draft application type.'
          requires :business_reference, type: String, desc: 'Draft application reference number.'
        end
        post 'draft_updated' do
          Operations::DraftUpdated.new(**declared(params).symbolize_keys).call
        end

        desc 'Create a DraftDeleted event for an application.'
        route_setting :authorised_consumers, %w[crime-apply crime-apply-preprod]
        params do
          requires :entity_id, type: String, desc: 'Draft application UUID.'
          requires :entity_type, type: String, values: Types::APPLICATION_TYPES, desc: 'Draft application type.'
          requires :business_reference, type: String, desc: 'Draft application reference number.'
          requires :reason, type: String, values: Types::DELETION_REASONS, desc: 'Deletion reason.'
          requires :deleted_by, type: String, desc: 'Who the application was deleted by.'
        end
        post 'draft_deleted' do
          Operations::DraftDeleted.new(**declared(params).symbolize_keys).call
        end
      end
    end
  end
end
