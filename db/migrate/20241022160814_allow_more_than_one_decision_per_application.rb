class AllowMoreThanOneDecisionPerApplication < ActiveRecord::Migration[7.1]
  def change
    remove_index :decisions, :crime_application_id, unique: true
    add_index :decisions, :crime_application_id, unique: false
  end
end
