module Redactable
  extend ActiveSupport::Concern

  included do
    has_one :redacted_crime_application, dependent: :destroy

    before_create :store_redacted_payload, if: :submitted_application
  end

  def store_redacted_payload
    Rails.logger.debug { "==> Redacting application ID #{to_param}" }
    Redacting::Redact.new(self).process!
  end
end
