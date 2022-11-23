require 'laa_crime_schemas'

module Datastore
  class Base < Grape::API
    rescue_from Dynamoid::Errors::RecordNotFound do
      error!({ status: 404, error: 'Record not found' }, 404)
    end

    rescue_from Dynamoid::Errors::MissingRangeKey do
      error!({ status: 500, error: 'Missing range key' }, 500)
    end

    rescue_from Dynamoid::Errors::RecordNotUnique do
      error!({ status: 400, error: 'Record not unique' }, 400)
    end

    rescue_from LaaCrimeSchemas::Errors::ValidationError do |ex|
      error!({ status: 400, error: ex.message }, 400)
    end

    helpers do
      # Add helpers here
    end
  end
end
