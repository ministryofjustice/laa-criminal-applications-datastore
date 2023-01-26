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
    reviewed_at: :reviewed_at,
  }.freeze

  DEFAULT_SORT_BY = :submitted_at
  DEFAULT_DIRECTION = :desc

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :sort_direction, :string, default: DEFAULT_DIRECTION

  def apply_to_scope(scope)
    scope.order({ column => direction })
  end

  private

  def column
    SORT_COLUMNS.fetch(sort_by&.to_sym || DEFAULT_SORT_BY)
  end

  def direction
    SORT_DIRECTIONS.fetch(sort_direction&.to_sym || DEFAULT_DIRECTION)
  end
end
