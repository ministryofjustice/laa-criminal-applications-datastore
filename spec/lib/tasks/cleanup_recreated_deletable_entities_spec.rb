require 'rails_helper'

RSpec.describe 'cleanup_recreated_deletable_entities' do # rubocop:disable RSpec/DescribeClass
  subject(:run_task) { Rake::Task['cleanup_recreated_deletable_entities'].execute }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Rake.application.rake_require('tasks/cleanup_recreated_deletable_entities', [Rails.root.join('lib').to_s])
    Rake::Task.define_task(:environment)
  end

  include_context 'with published events'

  let(:crime_application) do
    CrimeApplication.create!(submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read))
  end
  let(:entity_id) { crime_application.id }
  let(:business_reference) { crime_application.reference }
  let(:entity_type) { crime_application.application_type }
  let(:event_stream) { "Deleting$#{business_reference}" }
  let(:current_date) { Time.zone.local(2025, 9, 6) }

  let(:events) do
    [
      Applying::DraftCreated, Time.zone.local(2023, 8, 31), { entity_id:, entity_type:, business_reference: },
      Applying::Submitted, Time.zone.local(2023, 9, 1), { entity_id:, entity_type:, business_reference: },
      Reviewing::SentBack, Time.zone.local(2023, 9, 4), { entity_id: entity_id,
                                                           entity_type: entity_type,
                                                           business_reference: business_reference,
                                                           reason: 'duplicate_application' }
    ]
  end

  let(:hard_delete_documents) { instance_double(Deleting::Handlers::HardDeleteDocuments) }
  let(:hard_delete_submitted_applications) { instance_double(Deleting::Handlers::HardDeleteSubmittedApplications) }
  let(:soft_deleted_event) { instance_double(Events::SoftDeleted, publish: true) }

  before do
    Rake::Task['cleanup_recreated_deletable_entities'].reenable
    stub_const('ENV', ENV.to_h.merge('DRY_RUN' => nil))

    allow(Deleting::Handlers::HardDeleteDocuments).to receive(:new).and_return(hard_delete_documents)
    allow(Deleting::Handlers::HardDeleteSubmittedApplications).to receive(:new)
      .and_return(hard_delete_submitted_applications)
    allow(hard_delete_documents).to receive(:call)
    allow(hard_delete_submitted_applications).to receive(:call)
    allow(Events::SoftDeleted).to receive(:new).and_return(soft_deleted_event)

    travel_to current_date
  end

  describe 'when a DeletableEntity exists for a hard-deleted application' do
    before do
      DeletableEntity.create!(business_reference: business_reference, review_deletion_at: Time.zone.local(2025, 9, 4))
      publish_events

      # Run automated deletion to soft delete, then hard delete
      Deleting::AutomateDeletion.call

      travel_to current_date + Deleting::SOFT_DELETION_PERIOD
      Deleting::AutomateDeletion.call

      # At this point, the DeletableEntity has been destroyed by UpdateReadModel.
      # Re-create an recreated DeletableEntity to simulate the bug.
      DeletableEntity.create!(business_reference: business_reference, review_deletion_at: 1.day.ago)
    end

    context 'when DRY_RUN is true' do
      before { stub_const('ENV', ENV.to_h.merge('DRY_RUN' => 'true')) }

      it 'does not remove the DeletableEntity' do
        expect { run_task }.not_to change(DeletableEntity, :count)
      end

      it 'logs that it would remove the recreated record' do
        expect { run_task }.to output(
          /Would remove recreated DeletableEntity for reference #{business_reference}/
        ).to_stdout
      end

      it 'logs the DRY RUN summary' do
        expect { run_task }.to output(/DRY RUN: Would remove 1 recreated DeletableEntity records/).to_stdout
      end
    end

    context 'when DRY_RUN is false' do
      it 'removes the recreated DeletableEntity' do
        expect { run_task }.to change(DeletableEntity, :count).by(-1)
      end

      it 'logs that it is removing the record' do
        expect { run_task }.to output(
          /Removing recreated DeletableEntity for reference #{business_reference}/
        ).to_stdout
      end

      it 'logs the summary' do
        expect { run_task }.to output(/Removed 1 recreated DeletableEntity records/).to_stdout
      end
    end
  end

  describe 'when a DeletableEntity exists for a non-hard-deleted application' do
    before do
      publish_events

      # The DeletableEntity is created by UpdateReadModel when events are published.
      # Update it so it's expired, triggering a soft delete.
      DeletableEntity.find_by(business_reference:).update!(review_deletion_at: Time.zone.local(2025, 9, 4))

      # Soft delete only - not hard deleted
      Deleting::AutomateDeletion.call
    end

    it 'does not remove the DeletableEntity' do
      expect { run_task }.not_to change(DeletableEntity, :count)
    end

    it 'logs that no records were removed' do
      expect { run_task }.to output(/Removed 0 recreated DeletableEntity records/).to_stdout
    end
  end

  describe 'when there are no expired DeletableEntity records' do
    it 'does not remove anything' do
      expect { run_task }.not_to change(DeletableEntity, :count)
    end

    it 'logs that no records were removed' do
      expect { run_task }.to output(/Removed 0 recreated DeletableEntity records/).to_stdout
    end
  end
end
