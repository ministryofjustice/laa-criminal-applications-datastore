class CreateSlipstreamAuditSelectionOutcomes < ActiveRecord::Migration[7.2]
  def change
    create_table :slipstream_audit_selection_outcomes, id: :uuid do |t|
      t.uuid :crime_application_id, null: false
      t.integer :business_reference, null: false,
                index: { unique: true, name: 'index_slipstream_audit_outcomes_on_reference' }
      t.string :office_code
      t.string :application_type
      t.jsonb :offences, null: false, default: []
      t.string :status, null: false
      t.integer :sample_rate, null: false
      t.datetime :sampled_at, null: false
      t.datetime :status_determined_at, null: false
      t.integer :maat_reference
      t.string :ioj_outcome
      t.datetime :submitted_at
      t.timestamps

      t.check_constraint "status IN ('not_selected', 'selected', 'confirmed', 'withdrawn')",
                         name: 'slipstream_audit_read_model_status_check'
      t.check_constraint 'sample_rate BETWEEN 1 AND 100',
                         name: 'slipstream_audit_read_model_sample_rate_check'

      t.index :status
      t.index :submitted_at
    end
  end
end
