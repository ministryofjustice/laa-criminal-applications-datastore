module Utils
  class OtherIncomeBenefitCalculator < OtherIncomeBase
    # eForms collects ‘Contribution-based Job Seekers Allowance(jsa)’ and ‘Other Benefits’
    # as two separate items while MAAT has only one 'other benefits' field.
    # Therefore annualized sum of all below income benefits is treated as 'other benefit' in MAAT
    OTHER_INCOME_BENEFIT_TYPES = %w[
      jsa
      other
    ].freeze

    def payment_types
      OTHER_INCOME_BENEFIT_TYPES
    end
  end
end
