module MAAT
  module Translators
    class MeansTranslator
      def initialize(maat_record:)
        @maat_record = maat_record
      end

      def translate
        return nil unless result

        LaaCrimeSchemas::Structs::TestResult.new(
          result:, assessed_by:, assessed_on:
        )
      end

      class << self
        def translate(maat_record:)
          new(maat_record:).translate
        end
      end

      private

      attr_reader :maat_record

      def assessed_on
        if passport_result_most_recent?
          maat_record.date_passport_created
        else
          maat_record.date_means_created
        end
      end

      def assessed_by
        if passport_result_most_recent?
          maat_record.passport_assessor_name
        else
          maat_record.means_assessor_name
        end
      end

      def result
        return passport_result if passport_result_most_recent?

        MeansResultTranslator.translate(maat_record:)
      end

      def passport_result
        PassportMeansResultTranslator.translate(
          maat_record.passport_result
        )
      end

      def passport_result_most_recent?
        return false if maat_record.date_passport_created.blank?
        return true if maat_record.date_means_created.blank?

        maat_record.date_passport_created > maat_record.date_means_created
      end
    end
  end
end
