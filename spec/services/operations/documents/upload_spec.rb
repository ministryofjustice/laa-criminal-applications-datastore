require 'rails_helper'

describe Operations::Documents::Upload do
  subject { described_class.new(usn:, file:, payload:) }

  let(:usn) { 123 }
  let(:file) { fixture_file_upload('test.pdf', 'application/pdf') }
  let(:payload) { { 'filename' => 'filename' } }

  describe '#call' do
    include_context 'with an S3 client'

    context 'when there is no error' do
      let(:stubbed_s3_client) do
        Aws::S3::Client.new(
          stub_responses: { put_object: {} }
        )
      end

      before do
        allow(Aws::S3::Client).to receive(:new).and_return(stubbed_s3_client)
      end

      it 'performs the upload and logs the operation' do
        expect(subject.call).to eq({ object_key: '123/filename', size: 14_077 })

        expect(logger).to have_received(:info).with(
          [
            '[Operations::Documents::Upload]',
            { object_key: '123/filename', file_type: 'application/pdf', size: 14_077 }.to_json
          ].join(' ')
        )
      end
    end

    context 'when there is an error' do
      let(:endpoint) { 'https://s3.eu-west-2.amazonaws.com/s3_bucket_name/123/filename' }

      before do
        stub_request(:put, endpoint)
          .to_raise(StandardError.new('boom!'))
      end

      it 'logs the operation and re-raises the exception' do
        expect { subject.call }.to raise_error(Errors::DocumentUploadError)

        expect(logger).to have_received(:error).with(
          [
            '[Operations::Documents::Upload]',
            { object_key: '123/filename', file_type: 'application/pdf', size: 14_077, error: 'boom!' }.to_json
          ].join(' ')
        )
      end
    end
  end
end
