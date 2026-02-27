module Operations
  module Documents
    class Delete
      include Traits::S3Operation

      attr_accessor :object_key

      def initialize(object_key:)
        @object_key = object_key
      end

      def call
        call_with_error_handling({ object_key: }) do
          object.delete

          {
            object_key:
          }
        end
      end
    end
  end
end
