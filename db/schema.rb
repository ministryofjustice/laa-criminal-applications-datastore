# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_13_102206) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crime_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "application"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status", default: "submitted", null: false
    t.datetime "submitted_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "returned_at", precision: nil
    t.virtual "searchable_text", type: :tsvector, as: "((to_tsvector('english'::regconfig, (application #>> '{client_details,applicant,first_name}'::text[])) || to_tsvector('english'::regconfig, (application #>> '{client_details,applicant,last_name}'::text[]))) || to_tsvector('english'::regconfig, (application ->> 'reference'::text)))", stored: true
    t.index ["searchable_text"], name: "index_crime_applications_on_searchable_text", using: :gin
  end

end
