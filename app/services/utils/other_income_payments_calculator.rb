module Utils
  class OtherIncomePaymentsCalculator
    OTHER_INCOME_PAYMENTS = %w[
      interest_investment
      student_loan_grant
      board_from_family
      rent
      financial_support_with_access
      from_friends_relatives
    ].freeze

    APPLICANT = 'applicant'.freeze
    PARTNER = 'partner'.freeze

    attr_reader :income_payments

    def initialize(income_payments:)
      @income_payments = income_payments
    end

    def call
      update_or_create_other_income_payment(APPLICANT) if total_other_income_payment(APPLICANT).positive?
      update_or_create_other_income_payment(PARTNER) if total_other_income_payment(PARTNER).positive?
      income_payments.reject { |p| p['payment_type'] == 'employment' }
    end

    private

    def update_or_create_other_income_payment(ownership_type)
      if other_income_payment?(ownership_type)
        update_other_income_payment(ownership_type)
      else
        create_other_income_payment(ownership_type)
      end
    end

    def other_income_payment?(ownership_type)
      income_payments.any? do |income_payment|
        income_payment['payment_type'] == 'other' && income_payment['ownership_type'] == ownership_type
      end
    end

    def update_other_income_payment(ownership_type)
      income_payments.select { |p| p['ownership_type'] == ownership_type }.map do |payment|
        next unless payment['payment_type'] == 'other'

        annual_other_amount = annualized_amount(payment['amount'], payment['frequency'])
        payment['amount'] = annual_other_amount + total_other_income_payment(ownership_type)
        payment['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
      end
    end

    def create_other_income_payment(ownership_type)
      income_payments.push(
        {
          'payment_type' => 'other',
          'amount' => total_other_income_payment(ownership_type),
          'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
          'ownership_type' => ownership_type,
          'metadata' => {}
        }
      )
    end

    def total_other_income_payment(ownership_type)
      amount = 0
      income_payments.select { |p| p['ownership_type'] == ownership_type }.each do |payment|
        if OTHER_INCOME_PAYMENTS.include? payment['payment_type']
          amount += annualized_amount(payment['amount'], payment['frequency'])
        end
      end
      amount
    end

    def annualized_amount(amount, frequency)
      Utils::AnnualizedAmountCalculator.annualized_amount(amount:, frequency:)
    end
  end
end
