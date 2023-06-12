module Operations
  class ListApplications
    def initialize(office_code:, status:, page:, per_page:, sort_by:, sort_direction:)
      @office_code = office_code
      @status = status
      @pagination = Pagination.new(page:, per_page:)
      @sorting = Sorting.new(sort_by:, sort_direction:)
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

      scope = scope.where(status:) if status.present?
      scope = scope.where(office_code:) if office_code.present?

      scope
    end
  end
end
