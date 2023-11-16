require 'laa_crime_schemas'

module Utils
  class WorkStreamCalculator
    attr_reader :first_court_name, :hearing_court_name

    def initialize(first_court_name:, hearing_court_name:)
      @first_court_name = first_court_name
      @hearing_court_name = hearing_court_name
    end

    def work_stream
      if extradition_case?
        LaaCrimeSchemas::Types::WorkStreamType['extradition']
      else
        LaaCrimeSchemas::Types::WorkStreamType['criminal_applications_team']
      end
    end

    private

    def extradition_case?
      first_court_hearing_name = @first_court_name.presence || @hearing_court_name
      first_court_hearing_name == "Westminster Magistrates' Court"
    end
  end
end
