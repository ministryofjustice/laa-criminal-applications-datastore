module Operations
  module Documents
    module Traits
      module S3Operation
        private

        def client
          @client ||= Aws::S3::Client.new(
            **{
              endpoint:,
              access_key_id:,
              secret_access_key:,
              region:
            }.compact_blank
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

        def object_key
          [prefix, filename].join
        end

        def prefix
          [usn, application_id].compact.join('/').concat('/')
        end

        def log(details)
          if $ERROR_INFO
            Rails.logger.error("[#{self.class.name}] #{details.merge(error: $ERROR_INFO.message).to_json}")
          else
            Rails.logger.info("[#{self.class.name}] #{details.to_json}")
          end
        end

        def access_key_id
          ENV.fetch('S3_ACCESS_KEY_ID', nil)
        end

        def secret_access_key
          ENV.fetch('S3_SECRET_ACCESS_KEY', nil)
        end

        def region
          ENV.fetch('S3_REGION', 'eu-west-2')
        end

        def bucket_name
          ENV.fetch('S3_BUCKET_NAME', nil)
        end

        # Endpoint is only used to fake a local S3 service
        def endpoint
          ENV.fetch('LOCAL_S3_FAKER_URL', nil)
        end
      end
    end
  end
end
