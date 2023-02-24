require 'rails_helper'

describe GrapeLogging::Loggers::JwtIssuer do
  let(:request) { instance_double(Rack::Request, env:) }
  let(:response) { nil }

  describe '#parameters' do
    subject { described_class.new.parameters(request, response) }

    context 'when there is `grape_jwt.payload` in the request env' do
      let(:env) { { 'grape_jwt.payload' => { 'iss' => 'foobar' } } }

      it 'returns the issuer' do
        expect(subject).to eq(issuer: 'foobar')
      end
    end

    context 'when there is no `grape_jwt.payload` in the request env' do
      let(:env) { {} }

      it 'returns a `nil` issuer' do
        expect(subject).to eq(issuer: nil)
      end
    end
  end
end
