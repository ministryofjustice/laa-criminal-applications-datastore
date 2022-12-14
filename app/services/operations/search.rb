module Operations
  class Search
    def initialize(search:, pagination:, scope: CrimeApplication)
      @search_filter = SearchFilter.new(search)
      @pagination = Pagination.new(pagination)
      @scope = scope
    end

    def call
      filter
      paginate
    end

    private

    attr_reader :search_filter, :pagination

    def filter
      @scope = search_filter.apply_to_scope(@scope)
    end

    def paginate
      @scope = pagination.apply_to_scope(@scope)
    end
  end
end
