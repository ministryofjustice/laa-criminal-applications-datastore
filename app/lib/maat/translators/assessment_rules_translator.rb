module MAAT
  module Translators
    class AssessmentRulesTranslator
      def initialize(maat_record:)
        @maat_record = maat_record
      end

      def translate
        return nil unless assessment_rules

        Types::AssessmentRules[assessment_rules]
      end

      class << self
        def translate(maat_record:)
          new(maat_record:).translate
        end
      end

      private

      attr_reader :maat_record

      def assessment_rules
        case maat_record.case_type
        when 'APPEAL CC'
          'appeal_to_crown_court'
        when 'COMMITAL'
          'committal_for_sentence'
        when 'EITHER WAY'
          infer_either_way_assessment_rules
        when 'INDICTABLE', 'CC ALREADY'
          'crown_court'
        when 'SUMMARY ONLY'
          'magistrates_court'
        end
      end

      def infer_either_way_assessment_rules
        maat_record.cc_rep_decision ? 'crown_court' : 'magistrates_court'
      end
    end
  end
end
