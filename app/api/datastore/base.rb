require 'laa_crime_schemas'

module Datastore
  class Base < Grape::API
    include Datastore::Concerns::Logging

    helpers Helpers::SortingParams
    helpers Helpers::PaginationParams

    rescue_from ActiveRecord::RecordNotFound do
      error!({ status: 404, error: 'Record not found' }, 404)
    end

    rescue_from ActiveRecord::RecordNotUnique do
      error!({ status: 400, error: 'Record not unique' }, 400)
    end

    rescue_from LaaCrimeSchemas::Errors::ValidationError do |ex|
      error!({ status: 400, error: ex.message }, 400)
    end

    rescue_from Errors::AlreadyReturned do
      error!({ status: 409, error: 'Already Returned' }, 409)
    end

    rescue_from Errors::AlreadyCompleted do
      error!({ status: 409, error: 'Already Completed' }, 409)
    end

    rescue_from Errors::AlreadyMarkedAsReady do
      error!({ status: 409, error: 'Already marked as ready' }, 409)
    end

    rescue_from Errors::DocumentUploadError do |ex|
      error!({ status: 400, error: ex.message }, 400)
    end
  end
end
