module Deleting
  module Commands
    class Exempt
      def initialize(business_reference:, reason:, exempt_until:)
        @business_reference = business_reference
        @reason = reason
        @exempt_until = exempt_until
      end

      def call
        repository.with_deletable(@business_reference) do |deletable|
          deletable.exempt(entity_id:, reason:, exempt_until:)
        end
      end

      private

      attr_reader :business_reference, :reason, :exempt_until

      def entity_id
        @entity_id ||= CrimeApplication.latest(business_reference).first.id
      end

      def repository
        @repository ||= Deleting::DeletableRepository.new
      end
    end
  end
end
