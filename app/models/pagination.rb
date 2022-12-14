class Pagination
  include ActiveModel::Model
  include ActiveModel::Attributes

  DEFAULT_PER_PAGE = 20
  DEFAULT_PAGE = 1
  MAX_PER_PAGE = 200

  attribute :page, :integer, default: DEFAULT_PAGE
  attribute :per_page, :integer, default: DEFAULT_PER_PAGE

  def apply_to_scope(scope)
    scope.page(page).per(per_page)
  end
end
