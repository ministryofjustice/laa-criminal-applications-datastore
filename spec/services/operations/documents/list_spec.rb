require 'rails_helper'

describe Operations::Documents::List do
  subject { described_class.new(usn:) }

  let(:usn) { 123 }

  describe '#call' do
    include_context 'with an S3 client'

    context 'when there is no error' do
      let(:stubbed_s3_client) do
        Aws::S3::Client.new(
          stub_responses: {
            list_objects_v2: { contents: [{ key: '123/filename', size: 50, last_modified: Time.zone.at(0) }] }
          }
        )
      end

      before do
        allow(Aws::S3::Client).to receive(:new).and_return(stubbed_s3_client)
      end

      it 'performs the listing and logs the operation' do
        expect(subject.call).to eq([{ last_modified: '1970-01-01T00:00:00Z', object_key: '123/filename', size: 50 }])

        expect(logger).to have_received(:info).with(
          [
            '[Operations::Documents::List]',
            { prefix: '123/', count: 1 }.to_json
          ].join(' ')
        )
      end
    end

    context 'when there is an error' do
      let(:endpoint) { 'https://s3.eu-west-2.amazonaws.com/s3_bucket_name?list-type=2&prefix=123/' }

      before do
        stub_request(:get, endpoint)
          .to_raise(StandardError.new('boom!'))
      end

      it 'logs the operation and re-raises the exception' do
        expect { subject.call }.to raise_error(Errors::DocumentUploadError)

        expect(logger).to have_received(:error).with(
          [
            '[Operations::Documents::List]',
            { prefix: '123/', count: nil, error: 'boom!' }.to_json
          ].join(' ')
        )
      end
    end
  end
end
