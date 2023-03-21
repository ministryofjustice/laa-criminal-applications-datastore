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
    returned_at: [:returned_at],
    reviewed_at: [:reviewed_at],
    submitted_at: [:submitted_at]
  }.freeze

  DEFAULT_SORT_BY = :submitted_at
  DEFAULT_DIRECTION = :desc

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :sort_direction, :string, default: DEFAULT_DIRECTION

  def apply_to_scope(scope)
    if order_params[:applicant_first_name] || order_params[:applicant_last_name]
      scope.order("lower(applicant_last_name) #{direction}, lower(applicant_first_name) #{direction}")
    else
      scope.order(**order_params)
    end
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
