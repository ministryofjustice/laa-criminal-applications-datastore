module Datastore
  module Entities
    module V1
      module MAAT
        class MeansDetails < Grape::Entity
          self.hash_access = :to_s

          expose :income_details, using: IncomeDetails, expose_nil: false
          expose :outgoings_details, using: OutgoingsDetails, expose_nil: false
          expose :capital_details, using: CapitalDetails, expose_nil: false

          private

          def income_details
            # Dividends are considered as income payments. To calculate the total 'Other Income', 2 capital_details
            # attributes 'trust_fund_yearly_dividend' and 'partner_trust_fund_yearly_dividend'
            # needs to be passed to income_details object and added to the total value of 'Other Income' in MAAT

            if object['capital_details'].present?
              object['income_details'].merge!('dividends' => dividends)
            else
              object['income_details']
            end
          end

          def dividends
            {
              'trust_fund_yearly_dividend' => object.dig('capital_details',
                                                         'trust_fund_yearly_dividend'),
              'partner_trust_fund_yearly_dividend' => object.dig('capital_details',
                                                                 'partner_trust_fund_yearly_dividend')
            }
          end
        end
      end
    end
  end
end
