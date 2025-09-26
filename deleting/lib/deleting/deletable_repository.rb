module Deleting
  class DeletableRepository
    delegate :store, to: :repository

    def initialize(event_store = Rails.configuration.event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_deletable(business_reference, &block)
      stream_name = Deleting.stream_name(business_reference)
      repository.with_aggregate(Deletable.new, stream_name, &block)
    end

    private

    attr_reader :repository
  end
end
