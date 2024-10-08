module Utils
  module MAAT
    class OtherIncomePaymentCalculator < OtherIncomeBase
      # eForms collects student_loan_grant, board_from_family, rent and financial_support_with_access
      # as separate items while MAAT has only one 'other income' field.
      # Therefore annualized sum of all below income payments is treated as 'other income' in MAAT
      OTHER_INCOME_PAYMENT_TYPES = %w[
        student_loan_grant
        board_from_family
        rent
        financial_support_with_access
        from_friends_relatives
        other
      ].freeze

      DIVIDEND = 'trust_fund_dividend'.freeze

      def payment_types
        OTHER_INCOME_PAYMENT_TYPES + [DIVIDEND]
      end
    end
  end
end
