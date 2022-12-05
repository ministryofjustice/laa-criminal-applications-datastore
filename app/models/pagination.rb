class Pagination < Dry::Struct
  attribute :total_pages, Types::Integer
  attribute :total_count, Types::Integer
  attribute :current_page, Types::Integer

  class << self
    def for_collection(collection)
      new(
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        current_page: collection.current_page
      )
    end
  end
end
