require 'rails_helper'

RSpec.describe MAAT::Translators::PassportMeansResultTranslator do
  expected_translations = [
    'PASS', 'passed',
    'TEMP', nil,
    'FAIL CONTINUE', nil,
    'FAIL', nil
  ]

  it_behaves_like 'a MAAT value translator', expected_translations
end
