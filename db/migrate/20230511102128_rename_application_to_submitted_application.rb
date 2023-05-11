class RenameApplicationToSubmittedApplication < ActiveRecord::Migration[7.0]
  def change
    change_table :crime_applications do |t|
      t.rename :application, :submitted_application
    end
  end
end
