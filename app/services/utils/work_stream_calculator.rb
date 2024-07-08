require 'laa_crime_schemas'

module Utils
  class WorkStreamCalculator
    EXTRADITION_COURT_NAMES = LaaCrimeSchemas::Types::EXTRADITION_COURT_NAMES

    attr_reader :application

    def initialize(application)
      @application = application
    end

    def work_stream
      LaaCrimeSchemas::Types::WorkStreamType[calculated_work_stream]
    end

    private

    def calculated_work_stream
      return 'extradition' if extradition_case?
      return 'criminal_applications_team_2' if self_employed? || self_assessment_tax_bill?

      'criminal_applications_team'
    end

    def self_employed?
      employment_types.include? LaaCrimeSchemas::Types::EmploymentType['self_employed']
    end

    def self_assessment_tax_bill?
      return false unless income_details

      income_details.applicant_self_assessment_tax_bill == 'yes' ||
        income_details.partner_self_assessment_tax_bill == 'yes'
    end

    # If first court hearing name is provided, we use this value and look no further.
    def extradition_case?
      return true if EXTRADITION_COURT_NAMES.include? case_details.first_court_hearing_name
      return false unless case_details.first_court_hearing_name.nil?

      EXTRADITION_COURT_NAMES.include? case_details.hearing_court_name
    end

    def employment_types
      return [] unless income_details

      income_details.employment_type | income_details.partner_employment_type
    end

    def income_details
      means_details&.income_details
    end

    delegate :case_details, :means_details, to: :application
  end
end
