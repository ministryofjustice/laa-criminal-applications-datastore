module MAAT
  module Translators
    class MeansResultTranslator
      def initialize(maat_record:)
        @maat_record = maat_record
      end

      def translate
        return nil unless means_result

        Types::TestResult[means_result]
      end

      class << self
        def translate(maat_record:)
          new(maat_record:).translate
        end
      end

      private

      attr_reader :maat_record

      def means_result
        case maat_record.means_result
        when /PASS/
          'passed'
        when /FAIL/
          crown_court_trial? ? 'passed_with_contribution' : 'failed'
        when /INEL/
          'failed'
        end
      end

      def crown_court_trial?
        assessment_rules == Types::AssessmentRules['crown_court']
      end

      def assessment_rules
        AssessmentRulesTranslator.new(maat_record:).translate
      end
    end
  end
end
