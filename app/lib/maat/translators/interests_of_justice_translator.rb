module MAAT
  module Translators
    class InterestsOfJusticeTranslator
      def initialize(maat_record:)
        @maat_record = maat_record
      end

      class << self
        def translate(maat_record:)
          new(maat_record:).translate
        end
      end

      def translate
        return nil unless result

        LaaCrimeSchemas::Structs::TestResult.new(
          result:, assessed_by:, assessed_on:, details:
        )
      end

      private

      def assessed_on
        maat_record.app_created_date
      end

      def assessed_by
        maat_record.ioj_assessor_name
      end

      def details
        maat_record.ioj_reason
      end

      def result
        InterestsOfJusticeResultTranslator.translate(maat_result)
      end

      def maat_result
        maat_record.ioj_appeal_result.presence || maat_record.ioj_result
      end

      attr_reader :maat_record
    end
  end
end
