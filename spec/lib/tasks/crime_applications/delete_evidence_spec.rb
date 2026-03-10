require 'rails_helper'

RSpec.describe 'crime_applications:delete_evidence' do # rubocop:disable RSpec/DescribeClass
  subject(:run_task) do
    Rake::Task['crime_applications:delete_evidence'].execute(task_args)
  end

  let(:task_args) do
    Rake::TaskArguments.new(
      %i[application_id s3_object_keys reason],
      [application_id, s3_object_keys, reason]
    )
  end

  let(:fixture_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
      'supporting_evidence' => [
        { 's3_object_key' => '123/abcdef1234', 'filename' => 'doc1.pdf', 'content_type' => 'application/pdf',
          'file_size' => 12 },
        { 's3_object_key' => '456/xyz789', 'filename' => 'doc2.pdf', 'content_type' => 'application/pdf',
          'file_size' => 34 }
      ]
    )
  end

  let!(:crime_application) { CrimeApplication.create!(submitted_application: fixture_data) }
  let(:application_id) { crime_application.id }
  let(:s3_object_keys) { '123/abcdef1234' }
  let(:reason) { 'data_breach' }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Rake.application.rake_require('tasks/crime_applications/delete_evidence', [Rails.root.join('lib').to_s])
    Rake::Task.define_task(:environment)
  end

  before do
    Rake::Task['crime_applications:delete_evidence'].reenable
    stub_const('ENV', ENV.to_h.merge('DRY_RUN' => nil))
  end

  context 'when the application is not found' do
    let(:application_id) { SecureRandom.uuid }

    it 'raises ActiveRecord::RecordNotFound' do
      expect { run_task }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when no S3 object keys are provided' do
    let(:s3_object_keys) { nil }

    it 'raises ArgumentError' do
      expect { run_task }.to raise_error(ArgumentError, 'No S3 object keys provided')
    end
  end

  context 'when the application has no supporting evidence' do
    let(:fixture_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
        'supporting_evidence' => []
      )
    end

    it 'raises StandardError' do
      expect { run_task }.to raise_error(StandardError, "No evidence found for application #{application_id}")
    end
  end

  context 'when DRY_RUN is true' do
    before { stub_const('ENV', ENV.to_h.merge('DRY_RUN' => 'true')) }

    it 'does not call Operations::Documents::Delete' do
      allow(Operations::Documents::Delete).to receive(:new)
      run_task
      expect(Operations::Documents::Delete).not_to have_received(:new)
    end

    it 'does not create any DeletionEntry records' do
      expect { run_task }.not_to change(DeletionEntry, :count)
    end

    it 'logs the remaining evidence keys after the intended deletions' do
      expect { run_task }.to output(
        %r{Remaining evidence expected after successful deletion:.*456/xyz789}
      ).to_stdout
    end

    it 'logs Done' do
      expect { run_task }.to output(/Done/).to_stdout
    end
  end

  context 'when DRY_RUN is false' do
    let(:delete_operation) { instance_double(Operations::Documents::Delete, call: nil) }

    before do
      allow(Operations::Documents::Delete).to receive(:new).and_return(delete_operation)
    end

    it 'calls Operations::Documents::Delete for the given key' do
      run_task
      expect(Operations::Documents::Delete).to have_received(:new).with(object_key: '123/abcdef1234')
      expect(delete_operation).to have_received(:call)
    end

    it 'creates a DeletionEntry for the deleted key' do
      expect { run_task }.to change(DeletionEntry, :count).by(1)
    end

    it 'creates the DeletionEntry with the correct attributes' do
      run_task
      entry = DeletionEntry.last
      expect(entry).to have_attributes(
        record_id: '123/abcdef1234',
        record_type: Types::RecordType['document'],
        business_reference: crime_application.reference.to_s,
        deleted_by: 'system_manual',
        deleted_from: Types::RecordSource['amazon_s3'],
        reason: 'data_breach',
        correlation_id: nil
      )
    end

    it 'logs the successful deletions' do
      expect { run_task }.to output(%r{Successful deletions.*123/abcdef1234}).to_stdout
    end

    it 'logs Done' do
      expect { run_task }.to output(/Done/).to_stdout
    end

    context 'with multiple S3 object keys' do
      let(:s3_object_keys) { '123/abcdef1234 456/xyz789' }

      it 'deletes each key' do
        run_task
        expect(Operations::Documents::Delete).to have_received(:new).with(object_key: '123/abcdef1234')
        expect(Operations::Documents::Delete).to have_received(:new).with(object_key: '456/xyz789')
      end

      it 'creates a DeletionEntry for each deleted key' do
        expect { run_task }.to change(DeletionEntry, :count).by(2)
      end
    end

    context 'when a deletion raises Errors::DocumentUploadError' do
      before do
        allow(delete_operation).to receive(:call).and_raise(Errors::DocumentUploadError, 'S3 error')
      end

      it 'logs the failed key' do
        expect { run_task }.to output(%r{Failed deletions.*123/abcdef1234}).to_stdout
      end

      it 'does not create a DeletionEntry for the failed key' do
        expect { run_task }.not_to change(DeletionEntry, :count)
      end

      it 'does not raise' do
        expect { run_task }.not_to raise_error
      end

      context 'when one key fails and another succeeds' do
        let(:s3_object_keys) { '123/abcdef1234 456/xyz789' }
        let(:failing_operation) { instance_double(Operations::Documents::Delete) }
        let(:succeeding_operation) { instance_double(Operations::Documents::Delete, call: nil) }

        before do
          allow(Operations::Documents::Delete)
            .to receive(:new).with(object_key: '123/abcdef1234').and_return(failing_operation)
          allow(Operations::Documents::Delete)
            .to receive(:new).with(object_key: '456/xyz789').and_return(succeeding_operation)
          allow(failing_operation).to receive(:call).and_raise(Errors::DocumentUploadError, 'S3 error')
        end

        it 'creates a DeletionEntry only for the successfully deleted key' do
          expect { run_task }.to change(DeletionEntry, :count).by(1)
          expect(DeletionEntry.last.record_id).to eq('456/xyz789')
        end

        it 'logs both successful and failed deletions in a single run' do
          expect { run_task }.to output(
            %r{Successful deletions.*456/xyz789.*Failed deletions.*123/abcdef1234}m
          ).to_stdout
        end
      end
    end
  end
end
