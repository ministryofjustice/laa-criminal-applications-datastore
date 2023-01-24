require 'rails_helper'

describe Operations::ReturnApplication do
  before do
    CrimeApplication.create(
      application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:return_details) do
    {
      reason: Types::RETURN_REASONS.sample,
      details: 'Detailed reason why the application is being returned'
    }
  end

  let(:service) { described_class.new(application_id:, return_details:) }

  describe '#call' do
    subject(:call) { service.call }

    let(:application) do
      CrimeApplication.find(application_id)
    end

    context 'with valid attributes' do
      it "updates the application's status to 'returned'" do
        expect { call }.to change { application.reload.status }
          .from('submitted').to('returned')
      end

      it "sets application's 'returned_at'" do
        expect { call }.to change { application.reload.returned_at.class }
          .from(NilClass).to(ActiveSupport::TimeWithZone)
      end

      context 'when application has already been returned' do
        before { application.update(returned_at: 1.day.ago) }

        it 'raises AlreadyReturned error' do
          expect { call }.to raise_error Errors::AlreadyReturned
        end
      end

      context 'when application is not found' do
        let(:application_id) { SecureRandom.uuid }

        it 'raises RecordNotFound error' do
          expect { call }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      describe 'ReturnDetails' do
        subject(:detail) { application.reload.return_details }

        before { call }

        describe '#reason' do
          subject(:reason) { detail.reason }

          it { is_expected.not_to be_nil }
        end

        describe '#detail' do
          subject(:reason) { detail.details }

          it { is_expected.to eq 'Detailed reason why the application is being returned' }
        end

        describe '#crime_application' do
          subject(:reason) { detail.crime_application }

          it { is_expected.to be application }
        end
      end
    end

    context 'with invalid reason type' do
      let(:return_details) do
        {
          reason: 'not_a_valid_type',
          details: 'Detailed reason why the application is being returned'
        }
      end

      it 'raises ActiveRecord::RecordInvalid error and does not update the application' do
        expect { call }.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: Reason is not included in the list'
        )

        expect(application.reload.status).to eq('submitted')
      end
    end
  end
end
