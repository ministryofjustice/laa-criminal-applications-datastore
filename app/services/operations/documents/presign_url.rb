module Operations
  module Documents
    class PresignUrl
      include Traits::S3Operation

      attr_reader :verb, :object_key, :s3_opts

      def initialize(verb, object_key:, s3_opts: {})
        @verb = verb
        @object_key = object_key
        @s3_opts = s3_opts.symbolize_keys!
      end

      def call
        call_with_error_handling({ object_key:, verb: }) do
          url = object.presigned_url(verb, s3_opts)

          {
            object_key:,
            url:,
          }
        end
      end
    end
  end
end
