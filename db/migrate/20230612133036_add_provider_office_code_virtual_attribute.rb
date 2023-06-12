class AddProviderOfficeCodeVirtualAttribute < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :crime_applications, :office_code, :virtual,
      as: "(submitted_application->'provider_details'->>'office_code')",
      type: :string, stored: true
    )
  end
end
