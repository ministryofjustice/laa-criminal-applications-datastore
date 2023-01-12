module Operations
  class ListApplications
    SORT_DIRECTIONS = {
      descending: :desc,
      ascending: :asc
    }.freeze

    # rubocop:disable Metrics/ParameterLists
    def initialize(office_code:, page:, per_page:, status:, sort:, order:)
      @office_code = office_code
      @page = page
      @per_page = per_page
      @status = status
      @order = order
      @sort_direction = SORT_DIRECTIONS.fetch(sort)
      @scope = CrimeApplication
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      return query.page(page).per(per_page) if order.present?

      query
        .order({ sort_by => sort_direction })
        .page(page).per(per_page)
    end

    private

    attr_reader :status, :office_code,
                :page, :per_page, :sort_direction, :order

    def query
      scope = @scope

      scope = scope.by_status(status) if status.present?
      scope = scope.by_office(office_code) if office_code.present?
      scope = scope.by_applicant_name(sort_direction) if order.present? && order == 'applicant_name'

      scope
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
