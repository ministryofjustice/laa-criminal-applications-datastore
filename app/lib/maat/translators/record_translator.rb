module MAAT
  module Translators
    class RecordTranslator
      def initialize(maat_record:)
        @maat_record = maat_record
      end

      class << self
        def translate(maat_record)
          new(maat_record:).translate
        end
      end

      def translate
        LaaCrimeSchemas::Structs::Decision.new(
          maat_id:, case_id:, reference:, interests_of_justice:,
          means:, funding_decision:, assessment_rules:
        )
      end

      private

      attr_reader :maat_record

      delegate :case_id, to: :maat_record

      def maat_id
        maat_record.maat_ref
      end

      def reference
        maat_record.usn
      end

      def interests_of_justice
        InterestsOfJusticeTranslator.translate(maat_record:)
      end

      def means
        MeansTranslator.translate(maat_record:)
      end

      def assessment_rules
        AssessmentRulesTranslator.translate(maat_record:)
      end

      # The MAAT API can return partially completed results. During reassessment,
      # the MAAT API maintains the previous funding decision until the means
      # assessment is completed. Therefore, funding decisions that exist without
      # a corresponding means result should be ignored.
      def funding_decision
        return if means.blank?

        if maat_record.cc_rep_decision.present?
          CrownCourtDecisionTranslator.translate(maat_record.cc_rep_decision)
        else
          FundingDecisionTranslator.translate(maat_record.funding_decision)
        end
      end
    end
  end
end
