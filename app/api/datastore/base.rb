require 'laa_crime_schemas'

module Datastore
  class Base < Grape::API
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

    helpers do
      params :pagination do
        optional(
          :page,
          type: Integer,
          default: Pagination::DEFAULT_PAGE,
          desc: 'Page to fetch.'
        )

        optional(
          :per_page,
          type: Integer,
          default: Pagination::DEFAULT_PER_PAGE,
          desc: 'Number of results to return per page.',
          values: 1..Pagination::MAX_PER_PAGE
        )
      end
    end
  end
end
