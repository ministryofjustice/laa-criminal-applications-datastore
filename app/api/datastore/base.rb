require 'laa_crime_schemas'

module Datastore
  class Base < Grape::API
    include Datastore::Concerns::Logging

    helpers Helpers::SortingParams
    helpers Helpers::PaginationParams

    helpers do
      def current_consumer
        env.fetch('grape_jwt.payload', {})['iss']
      end
    end

    rescue_from ActiveRecord::RecordNotFound do
      error!({ status: 404, error: 'Record not found' }, 404)
    end

    rescue_from LaaCrimeSchemas::Errors::ValidationError do |ex|
      Rails.error.report(ex, handled: true)

      error!({ status: 400, error: ex.message }, 400)
    end

    rescue_from Errors::AlreadySubmitted do
      error!({ status: 409, error: 'Application already submitted' }, 409)
    end

    rescue_from Errors::AlreadyReturned do
      error!({ status: 409, error: 'Application already returned' }, 409)
    end

    rescue_from Errors::AlreadyCompleted do
      error!({ status: 409, error: 'Application already completed' }, 409)
    end

    rescue_from Errors::AlreadyMarkedAsReady do
      error!({ status: 409, error: 'Application already marked as ready' }, 409)
    end

    rescue_from Errors::DocumentUploadError do |ex|
      error!({ status: 400, error: ex.message }, 400)
    end

    rescue_from Errors::NotValidForMAAT do |ex|
      Rails.error.report(ex, handled: true)

      error!({ status: 404, error: 'Record not found' }, 404)
    end

    rescue_from Errors::AlreadyArchived do
      error!({ status: 409, error: 'Application already archived' }, 409)
    end

    rescue_from Errors::CannotArchive do
      error!({ status: 409, error: 'Application cannot be archived' }, 409)
    end
  end
end
