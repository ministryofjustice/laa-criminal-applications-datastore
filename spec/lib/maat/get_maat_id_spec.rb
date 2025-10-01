require 'rails_helper'

describe MAAT::GetMAATId do
  subject(:get_maat_id) { described_class.new(http_client: http_client.call) }

  let(:http_client) { instance_double(MAAT::HttpClient, call: connection) }
  let(:response) { instance_double(Faraday::Response, body:) }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:usn) { 123_456 }
  let(:maat_id) { 60_123 }

  let(:body) { { 'maat_ref' => 60_123 } }

  before do
    allow(connection).to receive(:get) { response }
  end

  describe '#by_usn!' do
    subject(:get_by_usn!) { get_maat_id.by_usn!(usn) }

    it 'makes a GET request to the MAAT API USN path' do
      get_by_usn!

      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/usn/123456')
    end

    context 'when decision is empty found' do
      let(:body) { {} }

      it 'raises Errors::MAATRecordNotFound' do
        expect { get_by_usn! }.to raise_error(Errors::MAATRecordNotFound)
      end
    end

    context 'when decision found has no maat id' do
      let(:body) { { 'maat_ref' => nil } }

      it 'raises Errors::MAATRecordNotFound' do
        expect { get_by_usn! }.to raise_error(Errors::MAATRecordNotFound)
      end
    end
  end
end
