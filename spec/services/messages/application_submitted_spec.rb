require 'rails_helper'

describe Messages::ApplicationSubmitted do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(CrimeApplication, id: '123', application: { 'foo' => 'bar' })
  end

  let(:sqs_client) do
    instance_double(Aws::SQS::Client, send_message: true)
  end

  let(:queue_url) { 'http://sqs-test/queue-name' }

  before do
    allow(ENV).to receive(:fetch).with('SQS_MAAT_QUEUE_URL').and_return(queue_url)

    allow(Rails.logger).to receive(:info)
    allow(Shoryuken).to receive(:sqs_client).and_return(sqs_client)
  end

  describe '#publish' do
    before do
      subject.publish
    end

    it 'logs the action' do
      expect(Rails.logger).to have_received(:info)
    end

    it 'publishes the message to the MAAT queue' do
      expect(
        sqs_client
      ).to have_received(:send_message).with(
        queue_url: queue_url,
        message_body: '{"foo":"bar"}'
      )
    end
  end
end
