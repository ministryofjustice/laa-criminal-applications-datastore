require 'rails_helper'

RSpec.describe PrometheusMetrics::DeletionLogReporter do
  describe '.report' do
    let(:client) { instance_double(PrometheusExporter::Client) }

    before do
      allow(PrometheusExporter::Client).to receive(:default).and_return(client)
    end

    it 'sends the count as JSON to the Prometheus client' do
      allow(client).to receive(:send_json)

      described_class.report(99)

      expect(client).to have_received(:send_json).with(type: 'deletion_log', count: 99)
    end

    context 'when an error occurs' do
      before do
        allow(client).to receive(:send_json).and_raise(StandardError, 'connection refused')
      end

      it 'logs a warning and does not raise' do
        allow(Rails.logger).to receive(:warn)

        expect { described_class.report(10) }.not_to raise_error
        expect(Rails.logger).to have_received(:warn).with(/Failed to report deletion log metric: connection refused/)
      end
    end
  end
end
