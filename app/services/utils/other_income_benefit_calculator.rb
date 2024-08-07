module Utils
  class OtherIncomeBenefitCalculator < OtherPaymentCalculator
    OTHER_INCOME_BENEFIT_TYPES = %w[
      jsa
      other
    ].freeze

    def payment_types
      OTHER_INCOME_BENEFIT_TYPES
    end
  end
end
