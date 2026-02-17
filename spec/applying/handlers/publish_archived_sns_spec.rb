require 'rails_helper'

RSpec.describe Applying::Handlers::PublishArchivedSns do
  subject(:handler) { described_class.new }

  let(:application) do
    CrimeApplication.create!(
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
      archived_at: Time.zone.parse('2024-06-01 12:00:00')
    )
  end

  let(:event) do
    Applying::Archived.new(
      data: {
        entity_id: application.id,
        entity_type: application.application_type,
        business_reference: application.reference,
        archived_at: application.archived_at
      }
    )
  end

  it 'publishes the Events::Archived SNS notification' do
    archived_sns_event = instance_double(Events::Archived, publish: true)

    allow(Events::Archived).to receive(:new).with(application).and_return(archived_sns_event)

    handler.call(event)

    expect(archived_sns_event).to have_received(:publish)
  end
end
