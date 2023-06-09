class CreateRedactedCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    create_view :redacted_crime_applications
  end
end
