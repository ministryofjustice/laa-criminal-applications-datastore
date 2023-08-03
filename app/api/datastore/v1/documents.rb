module Datastore
  module V1
    class Documents < Base
      version 'v1', using: :path

      resource :documents do
        desc 'Get a presigned URL for uploading a file.'
        route_setting :authorised_consumers, %w[crime-apply]
        params do
          requires :object_key, type: String, desc: 'S3 object key.'
          optional :s3_opts, type: Hash, default: {}, desc: 'Additional signing configuration, like `expires_in`.'
        end
        put 'presign_upload' do
          Operations::Documents::PresignUrl.new(
            :put, **declared(params).symbolize_keys
          ).call
        end

        desc 'Get a presigned URL for downloading a file.'
        route_setting :authorised_consumers, %w[crime-apply crime-review]
        params do
          requires :object_key, type: String, desc: 'S3 object key.'
          optional :s3_opts, type: Hash, default: {}, desc: 'Additional signing configuration, like `expires_in`'
        end
        put 'presign_download' do
          Operations::Documents::PresignUrl.new(
            :get, **declared(params).symbolize_keys
          ).call
        end
      end
    end
  end
end
