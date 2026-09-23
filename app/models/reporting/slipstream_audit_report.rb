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

    # Counts, per offence, the applications confirmed for audit in the period.
    # Percentages are intentionally deferred until the reporting requirement is
    # agreed, as the meaningful denominator (eligible vs all submissions) is not
    # yet settled.
    def offence_sampling
      confirmed_by_offence.map do |offence, count|
        { offence: offence, confirmed_applications: count }
      end
    end

    def as_json(_options = {})
      { data:, offence_sampling: }
    end

    def range
      date.all_month
    end

    def date
      Date.strptime(period, YearMonthFormat::FORMAT).in_time_zone('London')
    end

    private

    def entry(outcome)
      outcome.slice(
        :office_code, :application_type, :maat_reference, :ioj_outcome,
        :offences, :status, :sample_rate, :sampled_at, :status_determined_at, :submitted_at
      ).symbolize_keys.merge(reference: outcome.business_reference)
    end

    def confirmed_by_offence
      SlipstreamAuditSelectionOutcome
        .submitted_between(range)
        .with_status('confirmed')
        .each_with_object(Hash.new(0)) do |outcome, totals|
          outcome.offences.each { |offence| totals[offence['name']] += 1 }
        end
    end
  end
end
