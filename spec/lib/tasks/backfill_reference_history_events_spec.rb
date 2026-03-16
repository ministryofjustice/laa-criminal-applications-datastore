require 'rails_helper'

RSpec.describe 'backfill_reference_history_events' do # rubocop:disable RSpec/DescribeClass
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Rake.application.rake_require('tasks/backfill_reference_history_events', [Rails.root.join('lib').to_s])
    Rake::Task.define_task(:environment)
  end

  describe 'backfill_archived_events' do
    subject(:run_task) { Rake::Task['backfill_archived_events'].execute }

    let(:event_store) { Rails.configuration.event_store }

    let(:archived_application) do
      CrimeApplication.create!(
        submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
        archived_at: Time.zone.parse('2024-06-01 12:00:00')
      )
    end

    let(:non_archived_application) do
      CrimeApplication.create!(
        submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
      )
    end

    before do
      Rake::Task['backfill_archived_events'].reenable
      stub_const('ENV', ENV.to_h.merge('DRY_RUN' => nil))
    end

    context 'when DRY_RUN is true' do
      before { stub_const('ENV', ENV.to_h.merge('DRY_RUN' => 'true')) }

      it 'does not publish any Deleting::Archived events' do
        archived_application

        expect { run_task }.not_to(change { event_store.read.of_type([Deleting::Archived]).to_a.count })
      end

      it 'logs that it would create an event for the archived application' do
        archived_application

        expect { run_task }.to output(
          /Would create Deleting::Archived event for application #{archived_application.id}/
        ).to_stdout
      end

      it 'logs the DRY RUN summary with the count' do
        archived_application

        expect { run_task }.to output(/DRY RUN: Would backfill 1 Deleting::Archived events/).to_stdout
      end

      it 'does not log anything for non-archived applications' do
        non_archived_application

        expect { run_task }.not_to output(
          /Would create Deleting::Archived event for application #{non_archived_application.id}/
        ).to_stdout
      end
    end

    context 'when DRY_RUN is false' do
      let(:archived_sns_event) { instance_double(Events::Archived, publish: true) }

      before do
        allow(Events::Archived).to receive(:new).and_return(archived_sns_event)
      end

      it 'publishes a Deleting::Archived event for the archived application' do
        archived_application

        expect { run_task }.to(change { event_store.read.of_type([Deleting::Archived]).to_a.count }.by(1))
      end

      it 'does not publish an event for non-archived applications' do
        non_archived_application

        expect { run_task }.not_to(change { event_store.read.of_type([Deleting::Archived]).to_a.count })
      end

      it 'logs that it is creating an event' do
        archived_application

        expect { run_task }.to output(
          /Creating Deleting::Archived event for application #{archived_application.id}/
        ).to_stdout
      end

      it 'logs the summary with the count' do
        archived_application

        expect { run_task }.to output(/Backfilled 1 Deleting::Archived events/).to_stdout
      end

      context 'when a Deleting::Archived event already exists for the application' do
        before do
          event_store.publish(
            Deleting::Archived.new(
              data: {
                business_reference: archived_application.reference,
                entity_id: archived_application.id,
                entity_type: archived_application.application_type,
                archived_at: archived_application.archived_at
              }
            )
          )
        end

        it 'does not publish a duplicate event' do
          expect { run_task }.not_to(change { event_store.read.of_type([Deleting::Archived]).to_a.count })
        end

        it 'logs the summary with a count of 0' do
          expect { run_task }.to output(/Backfilled 0 Deleting::Archived events/).to_stdout
        end
      end
    end
  end

  describe 'publish_soft_deleted_sns_events' do
    subject(:run_task) { Rake::Task['publish_soft_deleted_sns_events'].execute }

    let(:event_store) { Rails.configuration.event_store }
    let(:timestamp) { Time.zone.parse('2024-06-01 12:00:00') }

    let(:soft_deleted_application) do
      app = CrimeApplication.create!(
        submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
      )
      app.update!(soft_deleted_at: timestamp)
      app
    end

    let(:soft_deleted_event) do
      Deleting::SoftDeleted.new(
        data: {
          business_reference: soft_deleted_application.reference,
          reason: Types::DeletionReason['retention_rule'],
          deleted_by: 'system_automated'
        },
        metadata: { timestamp: }
      )
    end

    before do
      Rake::Task['publish_soft_deleted_sns_events'].reenable
      stub_const('ENV', ENV.to_h.merge('DRY_RUN' => nil, 'LIMIT' => nil, 'START_AFTER_ID' => nil))
      allow(Deleting::Handlers::PublishSoftDeletedSns).to receive(:new).and_return(double(call: nil)) # rubocop:disable RSpec/VerifiedDoubles
      soft_deleted_application
      event_store.publish(soft_deleted_event)
    end

    context 'when DRY_RUN is true' do
      before { stub_const('ENV', ENV.to_h.merge('DRY_RUN' => 'true')) }

      it 'does not publish any SNS events' do
        allow(Events::SoftDeleted).to receive(:new)

        run_task

        expect(Events::SoftDeleted).not_to have_received(:new)
      end

      it 'logs that it would publish an SNS event for the application' do
        expect { run_task }.to output(
          /Would publish Events::SoftDeleted SNS event for application #{soft_deleted_application.reference}/
        ).to_stdout
      end

      it 'logs the DRY RUN summary with the count' do
        expect { run_task }.to output(/DRY RUN: Would publish 1 Events::SoftDeleted SNS events/).to_stdout
      end
    end

    context 'when DRY_RUN is false' do
      let(:sns_event) { instance_double(Events::SoftDeleted, publish: true) }

      before do
        allow(Events::SoftDeleted).to receive(:new)
          .with(reference: soft_deleted_application.reference, soft_deleted_at: timestamp)
          .and_return(sns_event)
      end

      it 'publishes an SNS event for the soft deleted application' do
        run_task
        expect(sns_event).to have_received(:publish)
      end

      it 'logs that it is publishing an SNS event' do
        expect { run_task }.to output(
          /Publishing Events::SoftDeleted SNS event for application #{soft_deleted_application.reference}/
        ).to_stdout
      end

      it 'logs the summary with the count' do
        expect { run_task }.to output(/Published 1 Events::SoftDeleted SNS events/).to_stdout
      end

      context 'when there are multiple Deleting::SoftDeleted events for the same reference' do
        let(:duplicate_event) do
          Deleting::SoftDeleted.new(
            data: {
              business_reference: soft_deleted_application.reference,
              reason: Types::DeletionReason['retention_rule'],
              deleted_by: 'system_automated'
            },
            metadata: { timestamp: }
          )
        end

        before { event_store.publish(duplicate_event) }

        it 'publishes an SNS event for each Deleting::SoftDeleted event' do
          run_task
          expect(sns_event).to have_received(:publish).exactly(2).times
        end

        it 'logs the summary with the correct count' do
          expect { run_task }.to output(/Published 2 Events::SoftDeleted SNS events/).to_stdout
        end
      end
    end

    context 'when LIMIT is set' do
      let(:second_application) do
        app = CrimeApplication.create!(
          submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge('id' => SecureRandom.uuid,
                                                                                     'reference' => 6_000_099)
        )
        app.update!(soft_deleted_at: timestamp)
        app
      end

      let(:second_event) do
        Deleting::SoftDeleted.new(
          data: {
            business_reference: second_application.reference,
            reason: Types::DeletionReason['retention_rule'],
            deleted_by: 'system_automated'
          },
          metadata: { timestamp: }
        )
      end

      let(:sns_event) { instance_double(Events::SoftDeleted, publish: true) }

      before do
        stub_const('ENV', ENV.to_h.merge('DRY_RUN' => nil, 'LIMIT' => '1', 'START_AFTER_ID' => nil))
        second_application
        event_store.publish(second_event)
        allow(Events::SoftDeleted).to receive(:new).and_return(sns_event)
      end

      it 'only processes up to the limit' do
        run_task
        expect(sns_event).to have_received(:publish).once
      end

      it 'logs the correct count' do
        expect { run_task }.to output(/Published 1 Events::SoftDeleted SNS events/).to_stdout
      end
    end

    context 'when START_AFTER_ID is set' do
      let(:sns_event) { instance_double(Events::SoftDeleted, publish: true) }

      before do
        stub_const('ENV', ENV.to_h.merge('DRY_RUN' => nil, 'LIMIT' => nil,
                                         'START_AFTER_ID' => soft_deleted_event.event_id))
        allow(Events::SoftDeleted).to receive(:new).and_return(sns_event)
      end

      it 'does not process events before the start_after_id' do
        run_task
        expect(sns_event).not_to have_received(:publish)
      end

      it 'logs that no events were found to process' do
        expect { run_task }.to output(/Found 0 Deleting::SoftDeleted events to process/).to_stdout
      end
    end
  end
end
