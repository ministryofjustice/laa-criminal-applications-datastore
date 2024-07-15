require 'rails_helper'
require 'laa_crime_schemas'

describe Utils::WorkStreamCalculator do
  subject(:calculator) { described_class.new(application) }

  let(:application) do
    instance_double(
      LaaCrimeSchemas::Structs::CrimeApplication, case_details:, means_details:, is_means_tested:
    )
  end

  let(:first_court_name) { nil }
  let(:hearing_court_name) { 'Cardiff Crown Court' }
  let(:case_details) { instance_double(LaaCrimeSchemas::Structs::CaseDetails) }
  let(:means_details) { instance_double(LaaCrimeSchemas::Structs::MeansDetails, income_details:) }
  let(:income_details) { LaaCrimeSchemas::Structs::IncomeDetails.new }
  let(:is_means_tested) { 'yes' }

  before do
    allow(case_details).to receive_messages(
      hearing_court_name: hearing_court_name,
      first_court_hearing_name: first_court_name,
    )
  end

  describe 'Work stream calculation' do
    describe 'extradition determination' do
      subject(:is_extradition?) do
        calculator.work_stream == LaaCrimeSchemas::Types::WorkStreamType['extradition']
      end

      let(:means_details) { nil }

      context 'when first court hearing is not given and next court hearing Westminster magistrates court' do
        let(:hearing_court_name) { "Westminster Magistrates' Court" }
        let(:first_court_hearing_name) { nil }

        it { is_expected.to be true }
      end

      context 'when first court hearing Westminster magistrates court and next court hearing another' do
        let(:first_court_name) { "Westminster Magistrates' Court" }
        let(:hearing_court_name) { 'Cardiff Crown Court' }

        it { is_expected.to be true }
      end

      context 'when first court hearing another and next court hearing Westminster' do
        let(:hearing_court_name) { "Westminster Magistrates' Court" }
        let(:first_court_name) { 'Cardiff Crown Court' }

        it { is_expected.to be false }
      end
    end

    describe 'CAT 1 determination' do
      subject(:is_cat1?) do
        calculator.work_stream == LaaCrimeSchemas::Types::WorkStreamType['criminal_applications_team']
      end

      it 'is the default work stream' do
        expect(is_cat1?).to be true
      end
    end

    describe 'CAT 2 determination' do
      subject(:is_cat2?) do
        calculator.work_stream == LaaCrimeSchemas::Types::WorkStreamType['criminal_applications_team_2']
      end

      context 'when there are no means details' do
        let(:means_details) { nil }

        it { is_expected.to be false }
      end

      context 'when there are no income details' do
        let(:income_details) { nil }

        it { is_expected.to be false }
      end

      context 'when the applicant is not working' do
        let(:income_details) do
          LaaCrimeSchemas::Structs::IncomeDetails.new(employment_type: ['not_working'])
        end

        it { is_expected.to be false }
      end

      context 'when the applicant is self-employed' do
        let(:income_details) do
          LaaCrimeSchemas::Structs::IncomeDetails.new(employment_type: ['self_employed'])
        end

        it { is_expected.to be true }
      end

      context 'when the partner is self-employed' do
        let(:income_details) do
          LaaCrimeSchemas::Structs::IncomeDetails.new(
            employment_type: ['not_working'], partner_employment_type: %w[employed self_employed]
          )
        end

        it { is_expected.to be true }
      end

      context 'when the applicant has a self_assessment_tax_bill' do
        let(:income_details) do
          LaaCrimeSchemas::Structs::IncomeDetails.new(applicant_self_assessment_tax_bill: 'yes')
        end

        it { is_expected.to be true }
      end

      context 'when the partner has a self_assessment_tax_bill' do
        let(:income_details) do
          LaaCrimeSchemas::Structs::IncomeDetails.new(
            applicant_self_assessment_tax_bill: 'no', partner_self_assessment_tax_bill: 'yes'
          )
        end

        it { is_expected.to be true }
      end

      context 'when neither has a self_assessment_tax_bill' do
        let(:income_details) do
          LaaCrimeSchemas::Structs::IncomeDetails.new(
            applicant_self_assessment_tax_bill: 'no', partner_self_assessment_tax_bill: nil
          )
        end

        it { is_expected.to be false }
      end
    end

    describe 'Non-means tested determination' do
      subject(:is_non_means?) do
        calculator.work_stream == LaaCrimeSchemas::Types::WorkStreamType['non_means_tested']
      end

      context 'when `is_means_tested` is nil' do
        let(:is_means_tested) { nil }

        it { is_expected.to be false }
      end

      context 'when the application is not means tested' do
        it { is_expected.to be false }
      end

      context 'when the application is means tested' do
        let(:is_means_tested) { 'no' }

        it { is_expected.to be true }
      end
    end
  end
end
