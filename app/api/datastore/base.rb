module Datastore
  class Base < Grape::API
    rescue_from Dynamoid::Errors::RecordNotFound do
      error!({ status: 404, error: 'Record not found' }, 404)
    end

    helpers do
      # Add helpers here
    end
  end
end
