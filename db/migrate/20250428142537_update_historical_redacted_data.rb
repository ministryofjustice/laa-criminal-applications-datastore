class UpdateHistoricalRedactedData < ActiveRecord::Migration[7.2]
  def change
    CrimeApplication.find_each do |app|
      Redacting::Redact.new(app).process!(force: true)
      app.save!
    end
  end
end
