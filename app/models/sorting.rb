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
    reference: :reference,
    submitted_at: :submitted_at,
    returned_at: :returned_at,
  }.freeze

  DEFAULT_SORT_BY = :submitted_at
  DEFAULT_DIRECTION = :desc

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :direction, :string, default: DEFAULT_DIRECTION

  def apply_to_scope(scope)
    scope.order({ sort_column => sort_direction })
  end

  private

  def sort_column
    SORT_COLUMNS.fetch(sort_by.to_sym)
  end

  def sort_direction
    SORT_DIRECTIONS.fetch(direction.to_sym)
  end
end
