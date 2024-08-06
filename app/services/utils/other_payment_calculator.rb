module Utils
  class OtherPaymentCalculator
    APPLICANT = 'applicant'.freeze
    PARTNER = 'partner'.freeze
    OTHER = 'other'.freeze

    attr_reader :payments, :other_payment_types

    def initialize(payments:, other_payment_types:)
      @payments = payments
      @other_payment_types = other_payment_types
    end

    def call
      update_or_create_other_payment(APPLICANT) if total_other_payments_by_ownership(APPLICANT).positive?
      update_or_create_other_payment(PARTNER) if total_other_payments_by_ownership(PARTNER).positive?
      payments
    end

    private

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

      annual_other_amount = annualized_amount(other_payment['amount'], other_payment['frequency'])
      other_payment['amount'] = annual_other_amount + total_other_payments_by_ownership(ownership_type)
      other_payment['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
    end

    def create_other_payment(ownership_type)
      payments.push(
        {
          'payment_type' => OTHER,
          'amount' => total_other_payments_by_ownership(ownership_type),
          'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
          'ownership_type' => ownership_type,
          'metadata' => {}
        }
      )
    end

    def total_other_payments_by_ownership(ownership_type)
      payments
        .select { |p| p['ownership_type'] == ownership_type && other_payment_types.include?(p['payment_type']) }
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
