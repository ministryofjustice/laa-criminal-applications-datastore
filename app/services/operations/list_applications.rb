module Operations
  class ListApplications
    SORT_DIRECTIONS = {
      descending: :desc,
      ascending: :asc
    }.freeze

    def initialize(office_code:, page:, per_page:, status:, sort:)
      @office_code = office_code
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

    attr_reader :status, :office_code,
                :page, :per_page, :sort_direction

    def query
      scope = @scope

      scope = scope.by_status(status) if status.present?
      scope = scope.by_office(office_code) if office_code.present?

      scope
    end

    def sort_by
      case status
      when 'submitted', nil
        :submitted_at
      when 'returned'
        :returned_at
      when 'completed'
        :completed_at
      end
    end
  end
end
