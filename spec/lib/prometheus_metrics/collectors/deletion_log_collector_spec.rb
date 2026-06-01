require 'rails_helper'

RSpec.describe PrometheusMetrics::Collectors::DeletionLogCollector do
  subject(:collector) { described_class.new }

  describe '#type' do
    it 'returns deletion_log' do
      expect(collector.type).to eq('deletion_log')
    end
  end

  describe '#collect' do
    it 'observes the count from the parsed object' do
      collector.collect({ 'count' => 42 })

      metrics = collector.metrics
      expect(metrics.first.metric_text).to include('42')
    end
  end

  describe '#metrics' do
    it 'returns an array containing the gauge' do
      expect(collector.metrics).to be_an(Array)
      expect(collector.metrics.size).to eq(1)
    end
  end
end
