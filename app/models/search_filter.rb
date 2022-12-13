class SearchFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :application_ids, array: true, default: -> { [] }
  attribute :search_text, :string

  def active_filters
    attributes.compact_blank
  end

  def active?
    !active_filters.empty?
  end

  def apply_to_scope(scope)
    active_filters.each_pair do |key, value|
      case key.to_sym
      when :application_ids
        scope = scope.where(id: value)
      when :search_text
        query = value.split.join('&')
        scope = scope.where('searchable_text @@ to_tsquery(?)', query)
      else
        raise 'Filter not found'
      end
    end
    scope
  end
end
