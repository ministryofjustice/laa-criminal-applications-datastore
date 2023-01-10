require 'rails_helper'

RSpec.describe Operations::Dynamodb::GetApplication do
  subject { described_class.new(application_id) }

  let(:application_id) { '12345' }

  let(:query) { { id: application_id } }
  let(:document) { instance_double(described_class) }

  describe '#call' do
    context 'when application exists' do
      before do
        allow(
          Dynamodb::CrimeApplication
        ).to receive(:where).with(query).and_return([document])
      end

      it 'retrieves the application' do
        expect(subject.call).to be(document)
      end
    end
  end
end
