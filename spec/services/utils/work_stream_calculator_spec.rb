require 'rails_helper'
require 'laa_crime_schemas'

describe Utils::WorkStreamCalculator do
  subject { described_class.new(first_court_name:, hearing_court_name:) }

  let(:first_court_name) { nil }
  let(:hearing_court_name) { 'Cardiff Crown Court' }

  describe 'Work stream calculation' do
    describe 'extradition work stream' do
      context 'when calculating for an application with the next court hearing at Westminster magistrates court' do
        let(:hearing_court_name) { "Westminster Magistrates' Court" }

        it 'returns an extradition work stream value' do
          expect(subject.work_stream).to eq LaaCrimeSchemas::Types::WorkStreamType['extradition']
        end
      end

      context 'when calculating for an application with a first court hearing at Westminster magistrates court' do
        let(:first_court_name) { "Westminster Magistrates' Court" }

        it 'returns an extradition work stream value' do
          expect(subject.work_stream).to eq LaaCrimeSchemas::Types::WorkStreamType['extradition']
        end
      end
    end

    describe 'criminal_application_team work stream' do
      context 'when calculating for an application with the next court hearing not at Westminster magistrates court' do
        it 'returns an extradition work stream value' do
          expect(subject.work_stream).to eq LaaCrimeSchemas::Types::WorkStreamType['criminal_applications_team']
        end
      end

      context 'when calculating for an application with a first court hearing not at Westminster magistrates court' do
        let(:first_court_name) { 'Cardiff Crown Court' }

        it 'returns an extradition work stream value' do
          expect(subject.work_stream).to eq LaaCrimeSchemas::Types::WorkStreamType['criminal_applications_team']
        end
      end
    end
  end
end
