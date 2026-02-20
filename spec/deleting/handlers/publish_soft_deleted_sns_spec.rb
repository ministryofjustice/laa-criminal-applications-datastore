require 'rails_helper'

RSpec.describe Deleting::Handlers::PublishSoftDeletedSns do
  subject(:handler) { described_class.new }

  let(:application) do
    CrimeApplication.create!(
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:timestamp) { Time.zone.parse('2024-06-01 12:00:00') }

  let(:event) do
    Deleting::SoftDeleted.new(
      data: {
        business_reference: application.reference,
        reason: Types::DeletionReason['retention_rule'],
        deleted_by: 'system_automated'
      },
      metadata: {
        timestamp:
      }
    )
  end

  it 'publishes the Events::SoftDeleted SNS notification (one per business reference)' do
    soft_deleted_sns_event = instance_double(Events::SoftDeleted, publish: true)

    allow(Events::SoftDeleted).to receive(:new)
      .with(reference: application.reference, soft_deleted_at: timestamp)
      .and_return(soft_deleted_sns_event)

    handler.call(event)

    expect(soft_deleted_sns_event).to have_received(:publish)
  end
end
