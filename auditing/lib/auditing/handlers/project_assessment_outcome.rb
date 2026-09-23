module Auditing
  module Handlers
    # Projects the post-submission assessment attributes (MAAT reference and
    # interests of justice outcome) onto an existing read model row. Only
    # applications that were slipstream-audited at submission have a row, so
    # completions for non-audited applications are ignored. The business
    # reference is not unique across an application family (PSE children share
    # it), so match on the application id too.
    class ProjectAssessmentOutcome
      def call(event)
        outcome = SlipstreamAuditSelectionOutcome.find_by(
          business_reference: event.data.fetch(:business_reference),
          crime_application_id: event.data.fetch(:entity_id)
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
