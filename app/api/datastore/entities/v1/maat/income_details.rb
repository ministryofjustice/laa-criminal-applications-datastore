module Datastore
  module Entities
    module V1
      module MAAT
        class IncomeDetails < Grape::Entity
          include Transformer::MAAT

          self.hash_access = :to_s

          expose :income_payments, using: Payment, expose_nil: false
          expose :income_benefits, using: Payment, expose_nil: false
          expose :dependants, expose_nil: false
          expose :employment_type
          expose :employment_income_payments, expose_nil: false
          expose :manage_without_income, expose_nil: false
          expose :manage_other_details, expose_nil: false
          expose :dividends, expose_nil: false

          private

          def manage_other_details
            transform!('manage_other_details', rule: %w[means_details income_details])
          end

          # rubocop:disable Metrics/AbcSize
          def income_payments
            dividends = []
            if object.dig('dividends', 'trust_fund_yearly_dividend')
              dividends << dividend(object['dividends']['trust_fund_yearly_dividend'], 'applicant')
            end
            if object.dig('dividends', 'partner_trust_fund_yearly_dividend')
              dividends << dividend(object['dividends']['partner_trust_fund_yearly_dividend'], 'partner')
            end

            Utils::MAAT::OtherIncomePaymentCalculator.new(
              payments: (object['income_payments'] + dividends).map(&:deep_dup)
            ).call
          end
          # rubocop:enable Metrics/AbcSize

          def dividend(amount, ownership_type)
            {
              'amount' => amount,
              'frequency' =>	Utils::AnnualizedAmountCalculator::PAYMENT_FREQUENCY_TYPE[:annual],
              'metadata' =>	{},
              'payment_type' =>	Utils::MAAT::OtherIncomePaymentCalculator::DIVIDEND,
              'ownership_type' =>	ownership_type,
            }
          end

          def income_benefits
            Utils::MAAT::OtherIncomeBenefitCalculator.new(
              payments: object['income_benefits'].map(&:deep_dup),
            ).call
          end
        end
      end
    end
  end
end
