require 'rails_helper'

describe Operations::SupersedeApplication do
  subject { described_class.new(application_id:) }

  let(:application_id) { '47a93336-7da6-48ec-b139-808ddd555a41' }

  describe '#call' do
    before do
      CrimeApplication.create(
        application: JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read),
        status: :returned,
      )
    end

    context 'when an application is found' do
      let(:application) { CrimeApplication.find(application_id) }

      it 'sets the status to `superseded`' do
        expect { subject.call }.to change { application.reload.status }.from('returned').to('superseded')
      end
    end

    context 'when an application is not found' do
      let(:application_id) { '0c6551ef-88fe-403f-aa35-79268cba66b0' }

      it 'does not raise any error' do
        expect { subject.call }.not_to raise_error
      end
    end
  end
end
