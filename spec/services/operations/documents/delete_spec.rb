require 'rails_helper'

describe Operations::Documents::Delete do
  subject { described_class.new(object_key:) }

  let(:object_key) { 'MTIzL2ZpbGVuYW1l' }
  let(:decoded_object_key) { '123/filename' }

  describe '.new' do
    it 'decodes the object_key' do
      expect(subject.object_key).to eq(decoded_object_key)
    end
  end

  describe '#call' do
    include_context 'with an S3 client'
    include_context 'with a stubbed AWS credentials request'

    let(:endpoint) { 'https://s3.eu-west-2.amazonaws.com/s3_bucket_name/123/filename' }

    context 'when there is no error' do
      before do
        stub_request(:delete, endpoint)
          .to_return(status: 200, body: '', headers: {})
      end

      it 'performs the deletion of the object and logs the operation' do
        expect(subject.call).to eq({ object_key: decoded_object_key })

        expect(logger).to have_received(:info).with(
          [
            '[Operations::Documents::Delete]',
            { object_key: decoded_object_key }.to_json
          ].join(' ')
        )
      end
    end

    context 'when there is an error' do
      before do
        stub_request(:delete, endpoint)
          .to_raise(StandardError.new('boom!'))
      end

      it 'logs the operation and re-raises the exception' do
        expect { subject.call }.to raise_error(Errors::DocumentUploadError)

        expect(logger).to have_received(:error).with(
          [
            '[Operations::Documents::Delete]',
            { object_key: decoded_object_key, error: 'boom!' }.to_json
          ].join(' ')
        )
      end
    end
  end
end
