require 'rails_helper'

describe Messaging::EventsPublisher do
  subject { described_class.new }

  let(:event) do
    instance_double(
      Events::BaseEvent, name: 'test-event', message: { foo: 'bar' }
    )
  end

  describe '.publish' do
    let(:instance) { instance_double(described_class, publish: true) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'instantiates and call publish on the instance' do
      described_class.publish(event)
      expect(instance).to have_received(:publish)
    end
  end

  describe '#publish' do
    let(:sns_endpoint) { 'https://sns.eu-west-2.amazonaws.com' }

    before do
      allow(Rails.logger).to receive(:debug)

      stub_const(
        'ENV',
        ENV.to_h.merge(
          'EVENTS_SNS_TOPIC_ARN' => topic_arn,
          'EVENTS_SNS_TOPIC_KEY_ID' => 'topic_key_id',
          'EVENTS_SNS_TOPIC_SECRET' => 'topic_secret',
        )
      )
    end

    context 'when the publishing is enabled' do
      let(:topic_arn) { 'topic_arn' }

      before do
        stub_request(:post, sns_endpoint)
          .with(
            body: hash_including(
              'Action' => 'Publish',
              'Message' => '{"foo":"bar"}',
              'MessageAttributes.entry.1.Name' => 'event_name',
              'MessageAttributes.entry.1.Value.DataType' => 'String',
              'MessageAttributes.entry.1.Value.StringValue' => 'test-event',
              'TopicArn' => 'topic_arn',
            )
          ).to_return(status: 201, body: '')
      end

      it 'publishes the event to the SNS topic' do
        expect(subject.publish(event)).to be_truthy
        expect(a_request(:post, sns_endpoint)).to have_been_made
      end
    end

    context 'when the publishing is disabled' do
      let(:topic_arn) { nil }

      it 'does not publish the event and return false' do
        expect(subject.publish(event)).to be(false)
        expect(a_request(:post, sns_endpoint)).not_to have_been_made
      end
    end
  end
end
