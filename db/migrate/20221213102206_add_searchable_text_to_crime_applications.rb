class AddSearchableTextToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :crime_applications,
      :searchable_text,
      :virtual,
      type: :tsvector,
      as: search_text_vector,
      stored: true
    )

    add_index :crime_applications, :searchable_text, using: :gin
  end

  def search_text_vector
    "to_tsvector('english', application#>>'{client_details,applicant,first_name}') || \
     to_tsvector('english', application#>>'{client_details,applicant,last_name}') || \
     to_tsvector('english', application->>'reference')"
  end
end
