require 'laa_crime_schemas'

module Datastore
  class Base < Grape::API
    rescue_from ActiveRecord::RecordNotFound, Dynamoid::Errors::RecordNotFound do
      error!({ status: 404, error: 'Record not found' }, 404)
    end

    rescue_from Dynamoid::Errors::MissingRangeKey do
      error!({ status: 500, error: 'Missing range key' }, 500)
    end

    rescue_from ActiveRecord::RecordNotUnique, Dynamoid::Errors::RecordNotUnique do
      error!({ status: 400, error: 'Record not unique' }, 400)
    end

    rescue_from LaaCrimeSchemas::Errors::ValidationError do |ex|
      error!({ status: 400, error: ex.message }, 400)
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
