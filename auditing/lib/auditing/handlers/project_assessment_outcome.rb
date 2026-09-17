module Auditing
  module Handlers
    # Projects the post-submission assessment attributes (MAAT reference and
    # interests of justice outcome) onto an existing read model row. Only
    # applications that were slipstream-audited at submission have a row, so
    # completions for non-audited applications are ignored.
    class ProjectAssessmentOutcome
      def call(event)
        outcome = SlipstreamAuditSelectionOutcome.find_by(
          business_reference: event.data.fetch(:business_reference)
        )
        return unless outcome

        outcome.update!(
          maat_reference: event.data[:maat_reference],
          ioj_outcome: event.data[:ioj_outcome]
        )
      end
    end
  end
end
