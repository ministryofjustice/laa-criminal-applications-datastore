class AddStoredSearchableTextToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :crime_applications, :stored_searchable_text, :tsvector
    add_index :crime_applications, :stored_searchable_text, using: :gin
  end
end
