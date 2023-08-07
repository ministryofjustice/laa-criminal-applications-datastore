module Operations
  module Documents
    class Upload
      include Traits::S3Operation

      attr_accessor :usn, :file, :filename

      delegate :size, to: :tempfile

      def initialize(usn:, file:, payload:)
        @usn = usn
        @file = file
        @filename = payload.fetch('filename')
      end

      def call
        object.upload_file(tempfile)

        {
          object_key:,
          size:,
        }
      rescue StandardError => e
        raise Errors::DocumentUploadError, e
      ensure
        log(object_key:, file_type:, size:)
      end

      private

      def tempfile
        file.try(:tempfile) || file.try(:[], 'tempfile')
      end

      def file_type
        file.try(:content_type) || file.try(:[], 'type')
      end
    end
  end
end
