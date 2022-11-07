module Datastore
  class Base < Grape::API
    rescue_from Dynamoid::Errors::RecordNotFound do
      error!({ status: 404, error: 'Record not found' }, 404)
    end

    rescue_from Dynamoid::Errors::MissingRangeKey do
      error!({ status: 500, error: 'Missing range key' }, 500)
    end

    helpers do
      # Add helpers here
    end
  end
end
