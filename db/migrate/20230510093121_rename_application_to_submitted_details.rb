class RenameApplicationToSubmittedDetails < ActiveRecord::Migration[7.0]
  def change
    change_table :crime_applications do |t|
      t.rename :application, :submitted_details
    end
  end
end
