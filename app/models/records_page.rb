class RecordsPage < Dry::Struct
  attribute :pagination, Types.Instance(Pagination)
  attribute :records, Types::Array
end
