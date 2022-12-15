class SearchFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :application_ids, array: true, default: -> { [] }
  attribute :search_text, :string
  attribute :submitted_after, :datetime
  attribute :submitted_before, :datetime

  def active_filters
    attributes.compact_blank.keys
  end

  def apply_to_scope(scope)
    active_filters.each do |f|
      scope = send("filter_#{f}", scope)
    end

    scope
  end

  private

  def filter_submitted_after(scope)
    scope.where('submitted_at >  ?', submitted_after)
  end

  def filter_submitted_before(scope)
    scope.where('submitted_at <  ?', submitted_before)
  end

  def filter_application_ids(scope)
    scope.where(id: application_ids)
  end

  def filter_search_text(scope)
    query_text = search_text.split.join('&')
    scope.where('searchable_text @@ to_tsquery(?)', query_text)
  end
end
