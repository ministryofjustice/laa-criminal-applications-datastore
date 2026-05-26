require 'rails_helper'

RSpec.describe PrometheusMetrics::Collectors::DeletionLogCollector do
  subject(:collector) { described_class.new }

  describe '#type' do
    it 'returns deletion_log' do
      expect(collector.type).to eq('deletion_log')
    end
  end

  describe '#process' do
    it 'observes the count from the JSON payload' do
      collector.process({ 'count' => 42 }.to_json)

      metrics = collector.collect
      expect(metrics.first.metric_text).to include('42')
    end
  end

  describe '#collect' do
    it 'returns an array containing the gauge' do
      expect(collector.collect).to be_an(Array)
      expect(collector.collect.size).to eq(1)
    end
  end
end
