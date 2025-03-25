module Operations
  class ListApplications
    def initialize(office_code:, status:, exclude_archived:, page:, per_page:, sort_by:, sort_direction:) # rubocop:disable Metrics/ParameterLists
      @office_code = office_code
      @status = status
      @exclude_archived = exclude_archived
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

    attr_reader :office_code, :status, :exclude_archived, :pagination, :sorting

    def query
      scope = @scope

      scope = scope.where(status:) if status.present?
      scope = scope.where(office_code:) if office_code.present?
      scope = scope.where(archived: false) if exclude_archived

      scope
    end
  end
end
