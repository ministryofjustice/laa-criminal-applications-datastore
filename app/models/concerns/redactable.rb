module Redactable
  extend ActiveSupport::Concern

  included do
    has_one :personally_identifiable_details, dependent: :destroy

    after_initialize Redacting::CallbacksWrapper
    before_save      Redacting::CallbacksWrapper
    after_save       Redacting::CallbacksWrapper
  end
end
