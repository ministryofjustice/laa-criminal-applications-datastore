module Operations
  module Documents
    class List
      include Traits::S3Operation

      attr_accessor :usn

      def initialize(usn:)
        @usn = usn
      end

      def call
        documents = bucket.objects(prefix:).map do |obj|
          {
            object_key: obj.key,
            size: obj.size,
            last_modified: obj.last_modified.iso8601,
          }
        end
      rescue StandardError => e
        raise Errors::DocumentUploadError, e
      ensure
        log(prefix: prefix, count: documents.try(:count))
      end
    end
  end
end
