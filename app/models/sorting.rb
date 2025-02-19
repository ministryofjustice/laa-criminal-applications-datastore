class Sorting
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORT_DIRECTIONS = {
    desc: :desc,
    asc: :asc,
    descending: :desc,
    ascending: :asc,
  }.freeze

  SORT_COLUMNS = {
    applicant_name: [:applicant_last_name, :applicant_first_name],
    application_status: :application_status_sql,
    application_type: [:application_type],
    case_type: [:case_type],
    office_code: [:office_code],
    reference: [:reference],
    return_reason: [:return_reason],
    returned_at: [:returned_at],
    review_status: [:review_status],
    reviewed_at: [:reviewed_at],
    submitted_at: [:submitted_at]
  }.freeze

  APPLICATION_STATUS_ORDER = {
    application_received: 30,
    ready_for_assessment: 30,
    returned_to_provider: 20,
    assessment_completed: 10
  }.freeze

  DEFAULT_SORT_BY = :submitted_at
  DEFAULT_DIRECTION = :desc

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :sort_direction, :string, default: DEFAULT_DIRECTION

  def apply_to_scope(scope)
    scope.order(order_args)
  end

  private

  def order_args
    return Arel.sql(send(column_names)) if column_names.is_a? Symbol

    column_names.index_with { direction }
  end

  def column_names
    SORT_COLUMNS.fetch(sort_by.to_sym)
  end

  def direction
    SORT_DIRECTIONS.fetch(sort_direction.to_sym)
  end

  def application_status_sql
    cases = APPLICATION_STATUS_ORDER.map do |status, order|
      "WHEN '#{status}' THEN #{order}"
    end

    "CASE review_status #{cases.join ' '} ELSE 0 END #{direction.upcase}"
  end
end
