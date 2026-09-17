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

    # Aggregates, over all outcomes submitted in the period, the volume of each
    # offence and the percentage of those that were sampled (confirmed for
    # audit). This is not filtered by the +status+ param, as the percentage
    # needs both the sampled and total counts.
    def offence_sampling
      offence_totals.map do |offence, counts|
        {
          offence: offence,
          volume: counts[:volume],
          sampled: counts[:sampled],
          percentage_sampled: percentage(counts[:sampled], counts[:volume])
        }
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

    def offence_totals
      SlipstreamAuditSelectionOutcome.submitted_between(range).each_with_object(empty_totals) do |outcome, totals|
        outcome.offences.each do |offence|
          totals[offence['name']][:volume] += 1
          totals[offence['name']][:sampled] += 1 if outcome.status == 'confirmed'
        end
      end
    end

    def empty_totals
      Hash.new { |hash, key| hash[key] = { volume: 0, sampled: 0 } }
    end

    def percentage(sampled, volume)
      volume.zero? ? 0 : ((sampled.to_f / volume) * 100).round
    end
  end
end
