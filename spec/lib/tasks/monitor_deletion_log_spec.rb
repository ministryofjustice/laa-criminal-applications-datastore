require 'rails_helper'

RSpec.describe 'monitor_deletion_log' do # rubocop:disable RSpec/DescribeClass
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Rake.application.rake_require('tasks/monitor_deletion_log', [Rails.root.join('lib').to_s])
    Rake::Task.define_task(:environment)
  end

  before do
    Rake::Task['monitor_deletion_log'].reenable
    allow(PrometheusMetrics::DeletionLogReporter).to receive(:report)
  end

  def run_task
    Rake::Task['monitor_deletion_log'].execute
  end

  def create_deletion_entries(count)
    count.times do
      DeletionEntry.create!(
        record_id: SecureRandom.uuid,
        record_type: 'CrimeApplication',
        business_reference: rand(10_000_000..99_999_999).to_s,
        deleted_by: 'system',
        reason: 'retention_period_expired'
      )
    end
  end

  describe 'when there is no previous snapshot' do
    before { create_deletion_entries(1) }

    it 'creates a snapshot with the current count' do
      expect { run_task }.to change(DeletionLogSnapshot, :count).by(1)
    end

    it 'logs an initialisation message' do
      expect { run_task }.to output(/Deletion log monitor initialised/).to_stdout_from_any_process
    end

    it 'reports the metric to Prometheus' do
      run_task
      expect(PrometheusMetrics::DeletionLogReporter).to have_received(:report).with(1)
    end
  end

  describe 'when the count has increased' do
    before do
      DeletionLogSnapshot.create!(count: 5, recorded_at: 1.day.ago)
      create_deletion_entries(7)
    end

    it 'logs a positive daily report' do
      expect { run_task }.to output(/\+2 since last check/).to_stdout_from_any_process
    end
  end

  describe 'when the count has decreased' do
    before do
      DeletionLogSnapshot.create!(count: 10, recorded_at: 1.day.ago)
      create_deletion_entries(8)
    end

    it 'logs an error' do
      expect { run_task }.to output(/Deletion log has DECREASED/).to_stdout_from_any_process
    end
  end
end
