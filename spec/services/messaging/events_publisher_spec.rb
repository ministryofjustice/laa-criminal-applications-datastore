# TODO: Commented out for staging testing

# require 'rails_helper'
#
# describe Messaging::EventsPublisher do
#   subject { described_class.new }
#
#   let(:event) do
#     instance_double(
#       Events::BaseEvent, name: 'test-event', message: { foo: 'bar' }
#     )
#   end
#
#   before do
#     stub_request(:put, %r{http://([0-9.]*)/latest/api/token})
#       .with(
#         headers: {
#           'User-Agent' => 'aws-sdk-ruby3/3.178.0',
#           'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
#         }
#       )
#       .to_return(status: 200, body: '', headers: {})
#
#     stub_request(:get, %r{http://([0-9.]*)/latest/meta-data/iam/security-credentials})
#       .with(
#         headers: {
#           'User-Agent' => 'aws-sdk-ruby3/3.178.0',
#         }
#       )
#       .to_return(status: 200, body: '', headers: {})
#
#     stub_request(:post, 'https://sts.eu-west-2.amazonaws.com/')
#       .with(
#         body: { 'Action' => 'AssumeRoleWithWebIdentity', 'RoleArn' => 'role_arn',
# 'RoleSessionName' => /.*/, 'Version' => '2011-06-15', 'WebIdentityToken' => 'dfdsfhdifiugfyuvedhf' },
#         headers: {
#           'Accept' => '*/*',
#           'Accept-Encoding' => '',
#           'Content-Length' => '171',
#           'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8',
#           'User-Agent' =>
# 'aws-sdk-ruby3/3.178.0 ua/2.0 api/sts#3.178.0 os/macos#22 md/x86_64 lang/ruby#3.2.2 md/3.2.2 cfg/retry-mode#legacy'
#         }
#       )
#       .to_return(status: 200, body: '', headers: {})
#   end
#
#   describe '.publish' do
#     let(:instance) { instance_double(described_class, publish: true) }
#
#     before do
#       allow(described_class).to receive(:new).and_return(instance)
#     end
#
#     it 'instantiates and call publish on the instance' do
#       described_class.publish(event)
#       expect(instance).to have_received(:publish)
#     end
#   end
#
#   describe '#publish' do
#     let(:sns_endpoint) { 'https://sns.eu-west-2.amazonaws.com' }
#
#     before do
#       allow(Rails.logger).to receive(:debug)
#
#       stub_const(
#         'ENV',
#         ENV.to_h.merge(
#           'EVENTS_SNS_TOPIC_ARN' => topic_arn,
#           'EVENTS_SNS_TOPIC_KEY_ID' => 'topic_key_id',
#           'EVENTS_SNS_TOPIC_SECRET' => 'topic_secret',
#           'AWS_WEB_IDENTITY_TOKEN_FILE' => File.expand_path('../../fixtures/aws/web_identity_token',
#                                                             File.dirname(__FILE__)),
#           'AWS_ROLE_ARN' => 'role_arn'
#         )
#       )
#     end
#
#     context 'when the publishing is enabled' do
#       let(:topic_arn) { 'topic_arn' }
#
#       before do
#         stub_request(:post, sns_endpoint)
#           .with(
#             body: {
#               'Action' => 'Publish',
#               'Message' => '{"event_name":"test-event","data":{"foo":"bar"}}',
#               'MessageAttributes.entry.1.Name' => 'event_name',
#               'MessageAttributes.entry.1.Value.DataType' => 'String',
#               'MessageAttributes.entry.1.Value.StringValue' => 'test-event',
#               'TopicArn' => 'topic_arn',
#               'Version' => '2010-03-31',
#             }
#           ).to_return(status: 201, body: '')
#       end
#
#       it 'publishes the event to the SNS topic' do
#         expect(subject.publish(event)).to be_truthy
#         expect(a_request(:post, sns_endpoint)).to have_been_made
#       end
#     end
#
#     context 'when the publishing is disabled' do
#       let(:topic_arn) { nil }
#
#       it 'does not publish the event and return false' do
#         expect(subject.publish(event)).to be(false)
#         expect(a_request(:post, sns_endpoint)).not_to have_been_made
#       end
#     end
#   end
# end
