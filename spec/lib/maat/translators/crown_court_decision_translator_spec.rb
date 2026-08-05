require 'rails_helper'

RSpec.describe MAAT::Translators::CrownCourtDecisionTranslator do
  it_behaves_like 'a MAAT value translator', [
    'Granted - Passed Means Test', 'granted',
    'Granted - Failed Means Test', 'granted',
    'Refused - Ineligible', 'refused',
    'Failed - CfS Failed Means Test', 'refused'
  ].freeze
end
