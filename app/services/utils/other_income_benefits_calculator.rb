module Utils
  class OtherIncomeBenefitsCalculator
    OTHER_INCOME_BENEFITS = %w[
      jsa
    ].freeze

    APPLICANT = 'applicant'.freeze
    PARTNER = 'partner'.freeze
    OTHER = 'other'.freeze

    attr_reader :income_benefits

    def initialize(income_benefits:)
      @income_benefits = income_benefits
    end

    def call
      update_or_create_other_income_benefit(APPLICANT) if total_other_income_benefits_by_ownership(APPLICANT).positive?
      update_or_create_other_income_benefit(PARTNER) if total_other_income_benefits_by_ownership(PARTNER).positive?
      income_benefits
    end

    private

    def update_or_create_other_income_benefit(ownership_type)
      if other_income_benefit?(ownership_type)
        update_other_income_benefit(ownership_type)
      else
        create_other_income_benefit(ownership_type)
      end
    end

    def other_income_benefit?(ownership_type)
      income_benefits.any? do |income_benefit|
        income_benefit['payment_type'] == OTHER && income_benefit['ownership_type'] == ownership_type
      end
    end

    def update_other_income_benefit(ownership_type)
      other_income_benefit = income_benefits.find { |p| p['ownership_type'] == ownership_type && p['payment_type'] == OTHER }
      if other_income_benefit
        annual_other_amount = annualized_amount(other_income_benefit['amount'], other_income_benefit['frequency'])
        other_income_benefit['amount'] = annual_other_amount + total_other_income_benefits_by_ownership(ownership_type)
        other_income_benefit['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
      end
    end

    def create_other_income_benefit(ownership_type)
      income_benefits.push(
        {
          'payment_type' => OTHER,
          'amount' => total_other_income_benefits_by_ownership(ownership_type),
          'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
          'ownership_type' => ownership_type,
          'metadata' => {}
        }
      )
    end

    def total_other_income_benefits_by_ownership(ownership_type)
      income_benefits.
        select { |p| p['ownership_type'] == ownership_type && OTHER_INCOME_BENEFITS.include?(p['payment_type']) }.
        inject(0) do |total, payment|
          total += annualized_amount(payment['amount'], payment['frequency'])
          total
        end
    end

    def annualized_amount(amount, frequency)
      Utils::AnnualizedAmountCalculator.annualized_amount(amount:, frequency:)
    end
  end
end
