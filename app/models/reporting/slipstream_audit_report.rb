module Reporting
  # Lists the slipstream audit selection outcomes for applications submitted in
  # a given month, defaulting to those confirmed as suitable for audit after
  # submission. Consumed by Review to compile the slipstream audit report.
  class SlipstreamAuditReport
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :string
    attribute :status, :string, default: 'confirmed'

    def data
      SlipstreamAuditSelectionOutcome
        .submitted_between(range)
        .with_status(status)
        .order(submitted_at: :asc)
        .map { |outcome| entry(outcome) }
    end

    def as_json(_options = {})
      { data: }
    end

    def range
      date.all_month
    end

    def date
      Date.strptime(period, YearMonthFormat::FORMAT).in_time_zone('London')
    end

    private

    def entry(outcome)
      {
        reference: outcome.business_reference,
        office_code: outcome.office_code,
        application_type: outcome.application_type,
        status: outcome.status,
        sample_rate: outcome.sample_rate,
        sampled_at: outcome.sampled_at,
        status_determined_at: outcome.status_determined_at,
        submitted_at: outcome.submitted_at
      }
    end
  end
end
