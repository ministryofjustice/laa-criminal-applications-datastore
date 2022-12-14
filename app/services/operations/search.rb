module Operations
  class Search
    def initialize(search:, pagination:)
      @filter = SearchFilter.new(search)
      @pagination = Pagination.new(pagination)
      @scope = CrimeApplication
    end

    def call
      query
        .page(page).per(per_page)
    end

    private

    attr_reader :filter, :pagination

    delegate :page, :per_page, to: :pagination

    def query
      return @scope if filter.application_ids.empty?

      @scope.where(id: filter.application_ids)
    end

    def sort_by
      :submitted_at
    end
  end
end
