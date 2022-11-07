require 'rails_helper'

RSpec.describe Datastore::Entities::Healthcheck do
  subject { described_class.represent(model).as_json }

  describe '.represent' do
    context 'when success' do
      let(:model) { instance_double(Status::Healthcheck, status: 200, error: nil) }

      it { expect(subject).to eq({ status: 200, error: nil }) }
    end

    context 'when failure' do
      let(:model) { instance_double(Status::Healthcheck, status: 503, error: 'an error') }

      it { expect(subject).to eq({ status: 503, error: 'an error' }) }
    end
  end
end
