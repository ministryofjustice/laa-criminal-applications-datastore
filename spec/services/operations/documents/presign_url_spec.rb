require 'rails_helper'

describe Operations::Documents::PresignUrl do
  subject { described_class.new(verb, object_key:, s3_opts:) }

  let(:verb) { :get }
  let(:object_key) { '123/filename' }
  let(:s3_opts) { {} }

  describe '#call' do
    include_context 'with an S3 client'

    context 'when there is no error' do
      context 'when downloading files' do
        let(:verb) { :get }

        it 'generates a presigned URL for downloading and logs the operation' do
          result = subject.call

          expect(result[:object_key]).to eq(object_key)
          expect(result[:url]).to start_with(
            'https://s3.eu-west-2.amazonaws.com/s3_bucket_name/123/filename?X-Amz-Algorithm=AWS4-HMAC-SHA256'
          )

          expect(logger).to have_received(:info).with(
            [
              '[Operations::Documents::PresignUrl]',
              { object_key:, verb: }.to_json
            ].join(' ')
          )
        end
      end

      context 'when uploading files' do
        let(:verb) { :put }

        it 'generates a presigned URL for uploading and logs the operation' do
          result = subject.call

          expect(result[:object_key]).to eq(object_key)
          expect(result[:url]).to start_with(
            'https://s3.eu-west-2.amazonaws.com/s3_bucket_name/123/filename?X-Amz-Algorithm=AWS4-HMAC-SHA256'
          )

          expect(logger).to have_received(:info).with(
            [
              '[Operations::Documents::PresignUrl]',
              { object_key:, verb: }.to_json
            ].join(' ')
          )
        end
      end
    end

    context 'when there is an error' do
      let(:s3_opts) { { expires_in: 0 } } # forces an error in the AWS args validation

      it 'logs the operation and re-raises the exception' do
        expect { subject.call }.to raise_error(Errors::DocumentUploadError)

        expect(logger).to have_received(:error).with(
          [
            '[Operations::Documents::PresignUrl]',
            {
              object_key: object_key,
              verb: verb,
              error: 'expires_in value of 0 cannot be 0 or less.'
            }.to_json
          ].join(' ')
        )
      end
    end
  end
end
