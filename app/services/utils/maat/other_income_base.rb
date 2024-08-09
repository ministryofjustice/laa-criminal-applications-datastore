module Utils
  module MAAT
    class OtherIncomeBase
      APPLICANT = 'applicant'.freeze
      PARTNER = 'partner'.freeze
      OTHER = 'other'.freeze

      attr_reader :payments

      def initialize(payments:)
        @payments = payments.reject { |p| p['payment_type'] == 'employment' }
      end

      def call
        update_or_create_other_payment(APPLICANT) if total_other_payments_by_ownership(APPLICANT).positive?
        update_or_create_other_payment(PARTNER) if total_other_payments_by_ownership(PARTNER).positive?
        payments.reject { |p| payment_types_excluding_other.include? p['payment_type'] }
      end

      private

      def payment_types_excluding_other
        payment_types.reject { |payment_type| payment_type == OTHER }
      end

      def update_or_create_other_payment(ownership_type)
        if other_payment?(ownership_type)
          update_other_payment(ownership_type)
        else
          create_other_payment(ownership_type)
        end
      end

      def other_payment?(ownership_type)
        payments.any? do |payment|
          payment['payment_type'] == OTHER && payment['ownership_type'] == ownership_type
        end
      end

      def update_other_payment(ownership_type)
        other_payment = payments.find { |p| p['ownership_type'] == ownership_type && p['payment_type'] == OTHER }
        return unless other_payment

        income_payment_notes = income_payment_notes(ownership_type)

        other_payment['amount'] = total_other_payments_by_ownership(ownership_type)
        other_payment['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
        other_payment['metadata']['details'] += "\n\n#{income_payment_notes}\n"
      end

      def create_other_payment(ownership_type)
        payments.push(
          {
            'payment_type' => OTHER,
            'amount' => total_other_payments_by_ownership(ownership_type),
            'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
            'ownership_type' => ownership_type,
            'metadata' => {
              'details' => income_payment_notes((ownership_type))
            }
          }
        )
      end

      def income_payment_notes(ownership_type)
        other_payments_by_ownership(ownership_type).group_by { |h| h['ownership_type'] }.map do |owner, pymts|
          "#{owner}: #{pymts.map { |p| "#{p['payment_type']}:#{p['amount']}:#{p['frequency']}" }.join(', ')}"
        end.join(', ')
      end

      def other_payments_by_ownership(ownership_type)
        payments.select do |payment|
          payment['ownership_type'] == ownership_type && payment_types.include?(payment['payment_type'])
        end
      end

      def total_other_payments_by_ownership(ownership_type)
        other_payments_by_ownership(ownership_type)
          .inject(0) do |total, payment|
            total += annualized_amount(payment['amount'], payment['frequency'])
            total
          end
      end

      def annualized_amount(amount, frequency)
        Utils::AnnualizedAmountCalculator.annualized_amount(amount:, frequency:)
      end
    end
  end
end
