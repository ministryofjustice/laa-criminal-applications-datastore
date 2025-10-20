require 'rails_helper'

describe Operations::ReturnApplication do
  before do
    CrimeApplication.create(
      created_at: DateTime.new(2024, 12, 11),
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
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
  let(:event_stream) { Rails.configuration.event_store.read }

  describe '.new' do
    context 'when application is not found' do
      let(:application_id) { SecureRandom.uuid }

      it 'raises RecordNotFound error' do
        expect { service }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#call' do
    subject(:call) { service.call }

    let(:application) do
      CrimeApplication.find(application_id)
    end

    let(:returned_event) { instance_double(Events::Returned, publish: true) }

    context 'with valid attributes' do
      before do
        allow(
          Events::Returned
        ).to receive(:new).with(application).and_return(returned_event)
      end

      it "updates the application's status to 'returned'" do
        expect { call }.to change { application.reload.status }
          .from('submitted').to('returned')
      end

      it "updates the application's review status to 'returned_to_provider'" do
        expect { call }.to change { application.reload.review_status }.to('returned_to_provider')
      end

      it "sets application's 'returned_at'" do
        expect { call }.to change { application.reload.returned_at.class }
          .from(NilClass).to(ActiveSupport::TimeWithZone)
      end

      it "sets application's 'reviewed_at'" do
        expect { call }.to change { application.reload.reviewed_at.class }
          .from(NilClass).to(ActiveSupport::TimeWithZone)
      end

      it 'publishes a returned event' do
        call

        expect(
          returned_event
        ).to have_received(:publish)
      end

      it 'publishes a SentBack event with the expected attributes' do
        expect(event_stream.map(&:event_type)).to match []
        call
        event = event_stream.first
        expect(event_stream.map(&:event_type)).to match ['Reviewing::SentBack']
        expect(event.data).to eq({ entity_id: application_id, entity_type: 'initial',
                                   business_reference: 6_000_001 })
      end

      context 'with redacted application metadata' do
        before do
          call
        end

        let(:return_details) { { reason: Types::ReturnReason['clarification_required'], details: 'Some details' } }
        let(:redacted_metadata) { application.reload.redacted_crime_application.metadata }

        it 'updates the metadata' do # rubocop:disable RSpec/ExampleLength
          expect(
            redacted_metadata
          ).to eq(
            {
              'offence_class' => nil,
              'return_reason' => 'clarification_required',
              'returned_at' => application.returned_at.to_time.utc.iso8601(3),
              'reviewed_at' => application.reviewed_at.to_time.utc.iso8601(3),
              'review_status' => 'returned_to_provider',
              'status' => 'returned',
              'application_type' => 'initial',
              'created_at' => '2024-12-11T00:00:00.000Z',
              'submitted_at' => '2022-10-24T09:50:04.019Z',
              'office_code' => '1A123B',
              'work_stream' => 'criminal_applications_team_2'
            }
          )
        end
      end

      context 'when application has already been returned' do
        before { application.update(status: :returned, returned_at: 1.day.ago) }

        it 'raises AlreadyReturned error' do
          expect { call }.to raise_error Errors::AlreadyReturned
        end
      end
    end
  end
end
