module Operations
  module Documents
    module Traits
      module S3Operation
        private

        def client
          @client ||= Aws::S3::Client.new(
            **{
              endpoint:,
              credentials:,
              region:
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

        def credentials
          Aws::AssumeRoleWebIdentityCredentials.new(
            role_arn: ENV.fetch('AWS_ROLE_ARN'),
            web_identity_token_file: ENV.fetch('AWS_WEB_IDENTITY_TOKEN_FILE'),
            region: region
          )
        end

        def region
          ENV.fetch('AWS_REGION', 'eu-west-2')
        end

        # Endpoint is only used to fake a local S3 service
        def endpoint
          ENV.fetch('AWS_ENDPOINT_URL', nil)
        end
      end
    end
  end
end
