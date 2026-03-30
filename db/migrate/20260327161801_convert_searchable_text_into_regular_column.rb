class ConvertSearchableTextIntoRegularColumn < ActiveRecord::Migration[7.2]
  def up
    remove_index :crime_applications, :searchable_text
    remove_column :crime_applications, :searchable_text
    add_column :crime_applications, :searchable_text, :tsvector
    add_index :crime_applications, :searchable_text, using: :gin
  end

  def down
    remove_index :crime_applications, :searchable_text
    remove_column :crime_applications, :searchable_text
    add_column :crime_applications, :searchable_text, :virtual,
               type: :tsvector, as: search_text_vector, stored: true
    add_index :crime_applications, :searchable_text, using: :gin
  end


  def search_text_vector
    "to_tsvector('english'::regconfig, submitted_application#>>'{client_details,applicant,first_name}'::text[]) || \
     to_tsvector('english'::regconfig, submitted_application#>>'{client_details,applicant,last_name}'::text[]) || \
     to_tsvector('english'::regconfig, submitted_application->>'reference'::text)"
  end
end
