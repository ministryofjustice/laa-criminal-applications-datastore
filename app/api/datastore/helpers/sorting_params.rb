module Datastore
  module Helpers
    module SortingParams
      extend Grape::API::Helpers

      params :sorting do
        optional(
          :sort_by,
          type: Symbol,
          description: 'Column to sort by the records.',
          default: Sorting::DEFAULT_SORT_BY,
          values: Sorting::SORT_COLUMNS.keys
        )

        optional(
          :sort_direction,
          type: Symbol,
          description: 'Sorting direction for the records.',
          default: Sorting::DEFAULT_DIRECTION,
          values: Sorting::SORT_DIRECTIONS.keys
        )
      end
    end
  end
end
