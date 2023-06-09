module Redacting
  class CallbacksWrapper
    class << self
      def after_initialize(record)
        after_save(record) unless record.new_record?
      end

      def before_save(record)
        Rails.logger.debug { "==> Redacting application ID #{record.id}" }
        Redacting::Redact.new(record).process! if record.submitted_application_changed?
      end

      def after_save(record)
        Rails.logger.debug { "==> Unredacting application ID #{record.id}" }
        Redacting::Unredact.new(record).process!
      end
    end
  end
end
