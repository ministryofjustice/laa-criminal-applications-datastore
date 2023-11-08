require 'rails_helper'
require 'laa_crime_schemas'

describe Utils::WorkStreamCalculator do
  subject { described_class.new(first_court_name:) }

  describe 'Work stream calculation' do
    context 'when calculating for an application with a first court hearing at Westminster magistrates court' do
      let(:first_court_name) { "Westminster Magistrates' Court" }

      it 'returns an extradition work stream value' do
        expect(subject.work_stream).to eq LaaCrimeSchemas::Types::WorkStreamType['extradition']
      end
    end

    context 'when calculating for an application with no Westminster magistrates court hearing' do
      let(:first_court_name) { 'Cardiff Crown Court' }

      it 'returns an criminal applications team work stream value' do
        expect(subject.work_stream).to eq LaaCrimeSchemas::Types::WorkStreamType['criminal_applications_team']
      end
    end
  end
end
