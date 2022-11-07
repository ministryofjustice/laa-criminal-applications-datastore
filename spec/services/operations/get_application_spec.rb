require 'rails_helper'

RSpec.describe Operations::GetApplication do
  subject { described_class.new(application_id) }

  let(:application_id) { '12345' }
  let(:document) { instance_double(CrimeApplication) }

  describe '#call' do
    context 'when application exists' do
      before do
        allow(
          CrimeApplication
        ).to receive(:find).with(application_id).and_return(document)
      end

      it 'retrieves the application' do
        expect(subject.call).to be(document)
      end
    end

    context 'when application does not exist' do
      it 'retrieves the application' do
        # TODO: investigate this as really should keep raising
        # `Dynamoid::Errors::RecordNotFound` but once a range key
        # is declared, the error changes to `Dynamoid::Errors::MissingRangeKey`
        # which is very misleading
        expect { subject.call }.to raise_error(Dynamoid::Errors::MissingRangeKey)
      end
    end
  end
end
