require 'rails_helper'

RSpec.describe MAAT::Translators::FundingDecisionTranslator do
  it_behaves_like 'a MAAT value translator', %w[
    PASS granted
    FAIL refused
    INEL refused
    FULL granted
    GRANTED granted
    FAILMEANS refused
    FAILIOJ refused
    FAILMEIOJ refused
  ]
end
