module Operations
  class ListApplications
    def initialize(office_code:, status:, page:, per_page:, order:, sort:)
      @office_code = office_code
      @status = status
      @pagination = Pagination.new(page:, per_page:)
      @sorting = Sorting.new(sort_by: order, direction: sort)
      @scope = CrimeApplication
    end

    def call
      pagination.apply_to_scope(
        sorting.apply_to_scope(
          query
        )
      )
    end

    private

    attr_reader :office_code, :status, :pagination, :sorting

    def query
      scope = @scope

      scope = scope.by_status(status) if status.present?
      scope = scope.by_office(office_code) if office_code.present?

      scope
    end
  end
end
