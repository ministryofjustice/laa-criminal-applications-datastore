require 'rails_helper'

RSpec.describe Deleting::Handlers::DeleteUnsubmittedDeletableEntity do
  include_context 'with published events'

  let(:event_stream) { "Deleting$#{business_reference}" }

  def publish_draft_deleted
    event_store.publish(Applying::DraftDeleted.new(data:
        {
          entity_id: entity_id, entity_type: entity_type,
          business_reference: business_reference,
          reason: 'retention_rule',
          deleted_by: SecureRandom.uuid
        }))
  end

  context 'when DraftDeleted is published for an unsubmitted application' do
    let(:entity_id) { SecureRandom.uuid }
    let(:business_reference) { '6000001' }
    let(:entity_type) { 'initial' }

    let(:events) do
      [
        Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: }
      ]
    end

    before do
      publish_events
    end

    it 'deletes the DeletableEntity record' do
      expect { publish_draft_deleted }.to change(DeletableEntity, :count).from(1).to(0)
    end
  end

  context 'when DraftDeleted is published for a submitted application' do
    let!(:crime_application) do
      CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
    end
    let(:entity_id) { crime_application.id }
    let(:business_reference) { crime_application.reference }
    let(:entity_type) { crime_application.application_type }

    let(:events) do
      [
        Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
        Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id:, entity_type:, business_reference: },
        Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: entity_id, entity_type: entity_type,
                                                              business_reference: business_reference,
                                                              reason: 'duplicate_application' },
        Applying::DraftCreated, Time.zone.local(2023, 9, 4), { entity_id:, entity_type:, business_reference: },
      ]
    end

    before do
      publish_events
    end

    it 'does not delete the DeletableEntity record' do
      expect { publish_draft_deleted }.not_to change(DeletableEntity, :count).from(1)
    end
  end
end
