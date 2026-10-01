class AddSelectionReasonToSlipstreamAuditSelectionOutcomes < ActiveRecord::Migration[7.2]
  def change
    add_column :slipstream_audit_selection_outcomes, :selection_reason, :string

    add_check_constraint :slipstream_audit_selection_outcomes,
                         "selection_reason IS NULL OR selection_reason IN ('offence', 'age')",
                         name: 'slipstream_audit_read_model_selection_reason_check'
  end
end
