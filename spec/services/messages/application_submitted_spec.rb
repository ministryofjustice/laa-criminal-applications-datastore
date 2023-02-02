require 'rails_helper'

describe Messages::ApplicationSubmitted do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(CrimeApplication, id: '123', application: { 'foo' => 'bar' })
  end

  let(:sqs_client) do
    instance_double(Aws::SQS::Client, send_message: true)
  end

  before do
    allow(Rails.logger).to receive(:info)
    allow(Shoryuken).to receive(:sqs_client).and_return(sqs_client)
  end

  describe '#process' do
    before do
      subject.process
    end

    it 'logs the action' do
      expect(Rails.logger).to have_received(:info)
    end

    it 'publishes the message to the MAAT queue' do
      expect(
        sqs_client
      ).to have_received(:send_message).with(
        queue_url: 'http://localhost:9324/test_submitted_applications_for_maat',
        message_body: '{"foo":"bar"}'
      )
    end
  end
end
