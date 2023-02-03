require 'rails_helper'

describe ApplicationSubmittedJob do
  let(:messaging_class) { Messages::ApplicationSubmitted }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:queue) { double.as_null_object }

  before do
    allow(
      messaging_class
    ).to receive(:new).with(crime_application).and_return(queue)
  end

  describe '.queue_name' do
    it { expect(described_class.queue_name).to eq('datastore_submissions') }
  end

  describe '#perform' do
    before do
      described_class.perform_now(crime_application)
    end

    it 'calls the service to publish the message' do
      expect(queue).to have_received(:publish)
    end
  end
end
