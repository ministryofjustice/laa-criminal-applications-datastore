module Redactable
  extend ActiveSupport::Concern

  included do
    has_one :redacted_crime_application, dependent: :destroy, autosave: true

    before_save :perform_redacting, if: :submitted_application
  end

  def perform_redacting
    Rails.logger.debug { "==> Redacting application ID #{to_param}" }
    Redacting::Redact.new(self).process!
  end
end
