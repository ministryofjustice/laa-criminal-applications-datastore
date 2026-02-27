module Operations
  module Documents
    class List
      include Traits::S3Operation

      attr_accessor :usn

      def initialize(usn:)
        @usn = usn
      end

      def call
        call_with_error_handling(->(docs) { { prefix: prefix, count: docs.try(:count) } }) do
          bucket.objects(prefix:).map do |obj|
            {
              object_key: obj.key,
              size: obj.size,
              last_modified: obj.last_modified.iso8601,
            }
          end
        end
      end
    end
  end
end
