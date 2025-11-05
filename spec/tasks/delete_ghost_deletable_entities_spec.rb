require 'rails_helper'

Rails.application.load_tasks

describe 'delete_ghost_deletable_entities' do # rubocop:disable RSpec/DescribeClass
  let(:event_store) { Rails.configuration.event_store }

  let(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end

  let(:submitted_application_events) do
    [
      Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id: crime_application.id,
                                                              entity_type: crime_application.application_type,
                                                              business_reference: crime_application.reference },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: crime_application.id,
                                                              entity_type: crime_application.application_type,
                                                              business_reference: crime_application.reference },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: crime_application.id,
                                                              entity_type: crime_application.application_type,
                                                              business_reference: crime_application.reference },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: crime_application.id,
                                                              entity_type: crime_application.application_type,
                                                              business_reference: crime_application.reference },
      Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id: crime_application.id,
                                                          entity_type: crime_application.application_type,
                                                          business_reference: crime_application.reference },
      Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: crime_application.id,
                                                          entity_type: crime_application.application_type,
                                                          business_reference: crime_application.reference,
                                                          reason: 'duplicate_application' }
    ]
  end

  let(:existing_draft_events) do
    [
      Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id: '8fd99226-b0df-4bed-aa35-b10945a6644c',
                                                              entity_type: 'initial',
                                                              business_reference: '6000035' },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: '8fd99226-b0df-4bed-aa35-b10945a6644c',
                                                              entity_type: 'initial',
                                                              business_reference: '6000035' },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: '8fd99226-b0df-4bed-aa35-b10945a6644c',
                                                              entity_type: 'initial',
                                                              business_reference: '6000035' },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: '8fd99226-b0df-4bed-aa35-b10945a6644c',
                                                              entity_type: 'initial',
                                                              business_reference: '6000035' }
    ]
  end

  let(:deleted_draft_events) do
    [
      Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id: '6463442d-24d9-4233-826a-613bc1d4e76b',
                                                              entity_type: 'initial',
                                                              business_reference: '6000077' },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: '6463442d-24d9-4233-826a-613bc1d4e76b',
                                                              entity_type: 'initial',
                                                              business_reference: '6000077' },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: '6463442d-24d9-4233-826a-613bc1d4e76b',
                                                              entity_type: 'initial',
                                                              business_reference: '6000077' },
      Applying::DraftUpdated, Time.zone.local(2023, 8, 31), { entity_id: '6463442d-24d9-4233-826a-613bc1d4e76b',
                                                              entity_type: 'initial',
                                                              business_reference: '6000077' }
    ]
  end

  before do
    publish_events(submitted_application_events)
    publish_events(existing_draft_events)
    publish_events(deleted_draft_events)
    # append deletion event so as not trigger DeleteUnsubmittedDeletableEntity handler
    event_store.append(
      Applying::DraftDeleted.new(data: { entity_id: '6463442d-24d9-4233-826a-613bc1d4e76b',
                                         entity_type: 'initial',
                                         business_reference: '6000077',
                                         reason: 'provider_action',
                                         deleted_by: SecureRandom.uuid }),
      stream_name: 'Deleting$6000077'
    )
  end

  it 'deletes unsubmitted record with no active drafts' do
    expect { Rake::Task['delete_ghost_deletable_entities'].invoke }.to change(DeletableEntity, :count).from(3).to(2)
    expect(DeletableEntity.all.map(&:business_reference)).to match_array(%w[6000001 6000035])
  end

  def publish_events(events)
    events.each_slice(3) do |slice|
      event_class = slice[0]
      timestamp = slice[1]
      data = slice[2]
      event_store.with_metadata(timestamp:) do
        event_store.publish(event_class.new(data:))
      end
    end
  end
end
