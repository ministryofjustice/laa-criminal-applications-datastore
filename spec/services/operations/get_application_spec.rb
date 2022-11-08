require 'rails_helper'

RSpec.describe Operations::GetApplication do
  subject { described_class.new(application_id) }

  let(:application_id) { '12345' }

  let(:query) { { id: application_id } }
  let(:document) { instance_double(CrimeApplication) }

  describe '#call' do
    context 'when application exists' do
      before do
        allow(
          CrimeApplication
        ).to receive(:where).with(query).and_return([document])
      end

      it 'retrieves the application' do
        expect(subject.call).to be(document)
      end
    end

    context 'when application does not exist' do
      it 'raises an exception' do
        expect { subject.call }.to raise_error(Dynamoid::Errors::RecordNotFound)
      end
    end
  end
end
