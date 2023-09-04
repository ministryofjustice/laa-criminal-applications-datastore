require 'rails_helper'

describe Messaging::EventsPublisher do
  subject { described_class.new }

  let(:event) do
    instance_double(
      Events::BaseEvent, name: 'test-event', message: { foo: 'bar' }
    )
  end

  # Example raw XML document received by Aws::AssumeRoleWebIdentityCredentials
  # https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html
  let(:sts_xml) do
    <<-XML
      <AssumeRoleWithWebIdentityResponse xmlns="https://sts.amazonaws.com/doc/2011-06-15/">
      <AssumeRoleWithWebIdentityResult>
        <SubjectFromWebIdentityToken>amzn1.account.AF6RHO7KZU5XRVQJGXK6HB56KR2A</SubjectFromWebIdentityToken>
        <Audience>client.5498841531868486423.1548@the-role-session-name</Audience>
        <AssumedRoleUser>
          <Arn>role_arn</Arn>
          <AssumedRoleId>AROACLKWSDQRAOEXAMPLE:the-role-session-name</AssumedRoleId>
        </AssumedRoleUser>
        <Credentials>
          <SessionToken>AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE</SessionToken>
          <SecretAccessKey>wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY</SecretAccessKey>
          <Expiration>2014-10-24T23:00:23Z</Expiration>
          <AccessKeyId>ASgeIAIOSFODNN7EXAMPLE</AccessKeyId>
        </Credentials>
        <SourceIdentity>SourceIdentityValue</SourceIdentity>
        <Provider>www.amazon.com</Provider>
      </AssumeRoleWithWebIdentityResult>
      <ResponseMetadata>
        <RequestId>ad4156e9-bce1-11e2-82e6-6b6efEXAMPLE</RequestId>
      </ResponseMetadata>
      </AssumeRoleWithWebIdentityResponse>
    XML
  end

  before do
    stub_request(:post, 'https://sts.eu-west-2.amazonaws.com/')
      .with(
        body: {
          'Action' => 'AssumeRoleWithWebIdentity',
          'RoleArn' => 'role_arn',
          'RoleSessionName' => /.*/,
          'Version' => '2011-06-15',
          'WebIdentityToken' => /.*/
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => '',
          'Content-Length' => '796',
          'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8',
          'User-Agent' => %r{aws-sdk-ruby3/.*}
        }
      )
      .to_return(status: 200, body: sts_xml, headers: {})
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
          'AWS_WEB_IDENTITY_TOKEN_FILE' => File.expand_path('../../fixtures/aws/web_identity_token',
                                                            File.dirname(__FILE__)),
          'AWS_ROLE_ARN' => 'role_arn'
        )
      )
    end

    context 'when the publishing is enabled' do
      let(:topic_arn) { 'topic_arn' }

      before do
        stub_request(:post, sns_endpoint)
          .with(
            body: {
              'Action' => 'Publish',
              'Message' => '{"event_name":"test-event","data":{"foo":"bar"}}',
              'MessageAttributes.entry.1.Name' => 'event_name',
              'MessageAttributes.entry.1.Value.DataType' => 'String',
              'MessageAttributes.entry.1.Value.StringValue' => 'test-event',
              'TopicArn' => 'topic_arn',
              'Version' => '2010-03-31',
            }
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
