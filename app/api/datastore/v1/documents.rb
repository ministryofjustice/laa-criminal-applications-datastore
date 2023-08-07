module Datastore
  module V1
    class Documents < Base
      version 'v1', using: :path

      resource :documents do
        desc 'Get a presigned URL for uploading a file.'
        route_setting :authorised_consumers, %w[crime-apply]
        params do
          requires :object_key, type: String, desc: 'S3 object key.'
          optional :s3_opts, type: Hash, default: {}, desc: 'Additional S3 options, like `expires_in`.'
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
          optional :s3_opts, type: Hash, default: {}, desc: 'Additional S3 options, like `expires_in`'
        end
        put 'presign_download' do
          Operations::Documents::PresignUrl.new(
            :get, **declared(params).symbolize_keys
          ).call
        end

        desc 'List all documents for an application USN.'
        route_setting :authorised_consumers, %w[crime-apply crime-review]
        params do
          requires :usn, type: Integer, desc: 'Application USN.'
        end
        route_param :usn do
          get do
            Operations::Documents::List.new(
              **declared(params).symbolize_keys
            ).call
          end
        end

        desc 'Delete a document.'
        route_setting :authorised_consumers, %w[crime-apply]
        params do
          requires :object_key, type: String, desc: 'S3 object key to delete, Base64 encoded.'
        end
        route_param :object_key do
          delete do
            Operations::Documents::Delete.new(
              object_key: params[:object_key]
            ).call
          end
        end
      end
    end
  end
end
