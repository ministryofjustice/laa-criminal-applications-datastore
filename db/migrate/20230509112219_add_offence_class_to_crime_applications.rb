class AddOffenceClassToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(:crime_applications, :offence_class, :string)
  end
end
