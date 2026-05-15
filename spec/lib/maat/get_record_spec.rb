require 'rails_helper'

RSpec.describe MAAT::GetRecord do
  subject(:get_record) { described_class.new(http_client: http_client.call) }

  let(:http_client) { instance_double(MAAT::HttpClient, call: connection) }
  let(:response) { instance_double(Faraday::Response, body:) }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:usn) { 123_456 }
  let(:maat_id) { 60_123 }

  let(:body) { { 'maat_ref' => 60_123, 'funding_decision' => 'GRANTED' } }

  before do
    allow(connection).to receive(:get) { response }
    allow(MAAT::Record).to receive(:new).with(body) { instance_double(MAAT::Record) }
  end

  describe '#by_usn' do
    before { get_record.by_usn(usn) }

    it 'makes a GET request to the MAAT API USN path' do
      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/usn/123456')

      expect(MAAT::Record).to have_received(:new).with(body)
    end

    context 'when decision is empty found' do
      let(:body) { {} }

      it 'returns nil' do
        expect(MAAT::Record).not_to have_received(:new)
      end
    end

    context 'when decision found has no maat id' do
      let(:body) { { 'maat_ref' => nil } }

      it 'returns nil' do
        expect(MAAT::Record).not_to have_received(:new)
      end
    end
  end

  describe '#by_usn!' do
    subject(:get_by_usn!) { get_record.by_usn!(usn) }

    it 'makes a GET request to the MAAT API USN path' do
      get_by_usn!

      expect(MAAT::Record).to have_received(:new).with(body)
    end

    context 'when decision is empty found' do
      let(:body) { {} }

      it 'raises MAAT::RecordNotFound' do
        expect { get_by_usn! }.to raise_error(MAAT::RecordNotFound)
      end
    end

    context 'when decision found has no maat id' do
      let(:body) { { 'maat_ref' => nil } }

      it 'raises MAAT::RecordNotFound' do
        expect { get_by_usn! }.to raise_error(MAAT::RecordNotFound)
      end
    end
  end

  describe '#by_maat_id' do
    before { get_record.by_maat_id(maat_id) }

    it 'makes a GET request to the MAAT API ID path' do
      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/rep-order-id/60123')

      expect(MAAT::Record).to have_received(:new).with(body)
    end
  end
end
