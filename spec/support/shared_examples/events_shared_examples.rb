RSpec.shared_examples 'an event notification' do |options|
  subject { described_class.new(crime_application) }

  let(:name) { options[:name] }
  let(:message) { options[:message] }

  describe '#name' do
    it 'has a name' do
      expect(subject.name).to eq(name)
    end
  end

  describe '#message' do
    it 'has a message' do
      expect(subject.message).to eq(message)
    end
  end

  describe '#publish' do
    before do
      allow(Messaging::EventsPublisher).to receive(:publish)
    end

    it 'instantiates the publisher and publish itself' do
      subject.publish

      expect(
        Messaging::EventsPublisher
      ).to have_received(:publish).with(subject)
    end
  end
end
