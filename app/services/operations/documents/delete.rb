module Operations
  module Documents
    class Delete
      include Traits::S3Operation

      attr_accessor :object_key

      def initialize(object_key:)
        @object_key = object_key
      end

      def call
        object.delete

        {
          object_key:
        }
      rescue StandardError => e
        raise Errors::DocumentUploadError, e
      ensure
        log(object_key:)
      end
    end
  end
end
