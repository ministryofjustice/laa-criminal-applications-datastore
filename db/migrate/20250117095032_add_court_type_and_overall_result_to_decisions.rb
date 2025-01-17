class AddCourtTypeAndOverallResultToDecisions < ActiveRecord::Migration[7.1]
  def change
    add_column :decisions, :court_type, :string
    add_column :decisions, :overall_result, :string
  end
end
