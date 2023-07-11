class AddReturnDetailsToCrimeApplications < ActiveRecord::Migration[7.0]
  class ReturnDetails < ApplicationRecord
    belongs_to :crime_application
  end

  def up
    add_column :crime_applications, :return_details, :jsonb

    ReturnDetails.find_each do |rd|
      rd.crime_application.update_column(
        :return_details, { reason: rd.reason, details: rd.details }
      )
    end
  end

  def down
    remove_column :crime_applications, :return_details
  end
end
