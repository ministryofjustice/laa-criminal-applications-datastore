module Operations
  module Documents
    module Traits
      module S3Operation
        private

        def call_with_error_handling(log_details)
          result = yield
          result
        rescue StandardError => e
          raise Errors::DocumentUploadError, e
        ensure
          log(log_details.respond_to?(:call) ? log_details.call(result) : log_details)
        end

        def client
          @client ||= Aws::S3::Client.new(
            **{
              endpoint:
            }.merge(default_client_cfg).compact_blank
          )
        end

        def resource
          @resource ||= Aws::S3::Resource.new(client:)
        end

        def bucket
          resource.bucket(bucket_name)
        end

        def object
          bucket.object(object_key)
        end

        # :nocov:
        def object_key
          [prefix, filename].join
        end

        def prefix
          "#{usn}/"
        end
        # :nocov:

        def log(details)
          if $ERROR_INFO
            Rails.logger.error("[#{self.class.name}] #{details.merge(error: $ERROR_INFO.message).to_json}")
          else
            Rails.logger.info("[#{self.class.name}] #{details.to_json}")
          end
        end

        def default_client_cfg
          { force_path_style: true }
        end

        def bucket_name
          ENV.fetch('S3_BUCKET_NAME', nil)
        end

        # Endpoint is only used to fake a local S3 service
        def endpoint
          ENV.fetch('AWS_ENDPOINT_URL', nil)
        end
      end
    end
  end
end
