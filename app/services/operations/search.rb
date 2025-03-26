module Operations
  class Search
    attr_reader :search_filter, :pagination, :sorting

    def initialize(search:, pagination:, sorting:, consumer:, scope: CrimeApplication.consumer_scope(consumer))
      @search_filter = SearchFilter.new(search)
      @pagination = Pagination.new(pagination)
      @sorting = Sorting.new(sorting)
      @scope = scope
    end

    def call
      filter
      sort
      paginate
    end

    private

    def filter
      @scope = search_filter.apply_to_scope(@scope)
    end

    def sort
      @scope = sorting.apply_to_scope(@scope)
    end

    def paginate
      @scope = pagination.apply_to_scope(@scope)
    end
  end
end
