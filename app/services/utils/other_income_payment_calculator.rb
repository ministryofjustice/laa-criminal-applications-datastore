module Utils
  class OtherIncomePaymentCalculator < OtherPaymentCalculator
    OTHER_INCOME_PAYMENT_TYPES = %w[
      student_loan_grant
      board_from_family
      rent
      financial_support_with_access
      other
    ].freeze

    def payment_types
      OTHER_INCOME_PAYMENT_TYPES
    end
  end
end
