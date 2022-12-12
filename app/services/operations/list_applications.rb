module Operations
  class ListApplications
    SORT_DIRECTIONS = {
      descending: :desc,
      ascending: :asc
    }.freeze

    def initialize(page:, per_page:, status:, sort:)
      @page = page
      @per_page = per_page
      @status = status
      @sort_direction = SORT_DIRECTIONS.fetch(sort)
      @scope = CrimeApplication
    end

    def call
      query
        .order({ sort_by => sort_direction })
        .page(page).per(per_page)
    end

    private

    attr_reader :page, :per_page, :status, :sort_direction

    def query
      return @scope if status.nil?

      @scope.by_status(status)
    end

    def sort_by
      case status
      when 'submitted', nil
        :submitted_at
      when 'returned'
        :returned_at
      end
    end
  end
end
