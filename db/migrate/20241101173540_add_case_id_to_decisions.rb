class AddCaseIdToDecisions < ActiveRecord::Migration[7.1]
  def change
    add_column :decisions, :case_id, :string
  end
end
