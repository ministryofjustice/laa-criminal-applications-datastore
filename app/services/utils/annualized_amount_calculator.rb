module Utils
  class AnnualizedAmountCalculator
    PAYMENT_FREQUENCY_TYPE = {
      week: 'week',
      fortnight: 'fortnight',
      four_weeks: 'four_weeks',
      month: 'month',
      annual: 'annual'
    }.freeze

    class << self
      def annualized_amount(amount:, frequency:) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        return amount if amount.nil? || amount.zero?

        case frequency.to_s
        when PAYMENT_FREQUENCY_TYPE[:week]
          (amount * 52)
        when PAYMENT_FREQUENCY_TYPE[:fortnight]
          (amount * 26)
        when PAYMENT_FREQUENCY_TYPE[:four_weeks]
          (amount * 13)
        when PAYMENT_FREQUENCY_TYPE[:month]
          (amount * 12)
        when PAYMENT_FREQUENCY_TYPE[:annual]
          amount
        else
          raise "Invalid frequency #{frequency}"
        end
      end
    end
  end
end
