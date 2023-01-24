module Datastore
  module Helpers
    module PaginationParams
      extend Grape::API::Helpers

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
