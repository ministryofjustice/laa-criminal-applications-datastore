class AddIndexForOfficeCodeVirtualAttributeOnCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :crime_applications, :office_code
  end
end
