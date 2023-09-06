RSpec.shared_context 'with an S3 client' do
  let(:logger) { Rails.logger }

  before do
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)

    stub_const(
      'ENV',
      ENV.to_h.merge(
        'S3_BUCKET_NAME' => 's3_bucket_name',
        'AWS_REGION' => 'eu-west-2',
        'AWS_ACCESS_KEY_ID' => 'test',
        'AWS_SECRET_ACCESS_KEY' => 'test'
      )
    )
  end
end

RSpec.shared_examples 'a documents API endpoint' do
  context 'when is successful' do
    before do
      api_request
    end

    it 'returns http status 200' do
      expect(response).to have_http_status(:success)
    end
  end

  context 'when is unsuccessful' do
    before do
      allow(stubbed_operation).to receive(:call).and_raise(Errors::DocumentUploadError)
      api_request
    end

    it 'returns http status 400' do
      expect(response).to have_http_status(:bad_request)
    end
  end
end
