module Utils
  class OtherIncomeBenefitsCalculator
    OTHER_INCOME_BENEFITS = %w[
      jsa
    ].freeze

    APPLICANT = 'applicant'.freeze
    PARTNER = 'partner'.freeze

    attr_reader :income_benefits

    def initialize(income_benefits:)
      @income_benefits = income_benefits
    end

    def call
      update_or_create_other_income_benefit(APPLICANT) if total_other_income_benefit(APPLICANT).positive?
      update_or_create_other_income_benefit(PARTNER) if total_other_income_benefit(PARTNER).positive?
      income_benefits.reject { |p| p['payment_type'] == 'employment' }
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
        income_benefit['payment_type'] == 'other' && income_benefit['ownership_type'] == ownership_type
      end
    end

    def update_other_income_benefit(ownership_type)
      income_benefits.select { |p| p['ownership_type'] == ownership_type }.map do |payment|
        next unless payment['payment_type'] == 'other'

        annual_other_amount = annualized_amount(payment['amount'], payment['frequency'])
        payment['amount'] = annual_other_amount + total_other_income_benefit(ownership_type)
        payment['frequency'] = Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual]
      end
    end

    def create_other_income_benefit(ownership_type)
      income_benefits.push(
        {
          'payment_type' => 'other',
          'amount' => total_other_income_benefit(ownership_type),
          'frequency' => Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
          'ownership_type' => ownership_type,
          'metadata' => {
            'details' => "Details of the other #{ownership_type} benefit"
          }
        }
      )
    end

    def total_other_income_benefit(ownership_type)
      other_amount = 0
      income_benefits.select { |p| p['ownership_type'] == ownership_type }.each do |payment|
        if OTHER_INCOME_BENEFITS.include? payment['payment_type']
          other_amount += annualized_amount(payment['amount'], payment['frequency'])
        end
      end
      other_amount
    end

    def annualized_amount(amount, frequency)
      Utils::AnnualizedAmountCalculator.annualized_amount(amount:, frequency:)
    end
  end
end
