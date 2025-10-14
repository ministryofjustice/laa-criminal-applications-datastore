class AddMAATIdToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :crime_applications, :maat_id, :integer
  end
end
