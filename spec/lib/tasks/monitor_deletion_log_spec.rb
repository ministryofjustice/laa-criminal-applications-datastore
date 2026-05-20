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

  it 'reports the current count to Prometheus' do
    create_deletion_entries(3)
    run_task
    expect(PrometheusMetrics::DeletionLogReporter).to have_received(:report).with(3)
  end

  it 'logs the count' do
    create_deletion_entries(2)
    expect { run_task }.to output(/Deletion log count reported to Prometheus: 2/).to_stdout_from_any_process
  end
end
