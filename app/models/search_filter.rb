class SearchFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :application_ids, array: true, default: -> { [] }
end
