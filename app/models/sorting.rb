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
    application_type: [:application_type],
    case_type: [:case_type],
    office_code: [:office_code],
    reference: [:reference],
    return_reason: [:return_reason],
    returned_at: [:returned_at],
    reviewed_at: [:reviewed_at],
    submitted_at: [:submitted_at]
  }.freeze

  DEFAULT_SORT_BY = :submitted_at
  DEFAULT_DIRECTION = :desc

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :sort_direction, :string, default: DEFAULT_DIRECTION

  def apply_to_scope(scope)
    scope.order(**order_params)
  end

  private

  def order_params
    column_names.index_with { direction }
  end

  def column_names
    SORT_COLUMNS.fetch(sort_by.to_sym)
  end

  def direction
    SORT_DIRECTIONS.fetch(sort_direction.to_sym)
  end
end
