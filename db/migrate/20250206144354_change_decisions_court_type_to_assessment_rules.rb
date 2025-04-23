class ChangeDecisionsCourtTypeToAssessmentRules < ActiveRecord::Migration[7.1]
  def change
    rename_column :decisions, :court_type, :assessment_rules
  end
end
