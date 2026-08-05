require 'rails_helper'

RSpec.describe MAAT::Translators::PassportMeansResultTranslator do
  it_behaves_like 'a MAAT value translator', [
    'PASS', 'passed',
    'TEMP', nil,
    'FAIL CONTINUE', nil,
    'FAIL', nil
  ]
end
