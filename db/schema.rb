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

ActiveRecord::Schema[7.0].define(version: 2023_06_06_112337) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "crime_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "submitted_application"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "submitted", null: false
    t.datetime "submitted_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "returned_at", precision: nil
    t.virtual "searchable_text", type: :tsvector, as: "((to_tsvector('english'::regconfig, (submitted_application #>> '{client_details,applicant,first_name}'::text[])) || to_tsvector('english'::regconfig, (submitted_application #>> '{client_details,applicant,last_name}'::text[]))) || to_tsvector('english'::regconfig, (submitted_application ->> 'reference'::text)))", stored: true
    t.datetime "reviewed_at", precision: nil
    t.string "review_status", default: "application_received", null: false
    t.virtual "reference", type: :integer, as: "((submitted_application ->> 'reference'::text))::integer", stored: true
    t.virtual "applicant_first_name", type: :citext, as: "(submitted_application #>> '{client_details,applicant,first_name}'::text[])", stored: true
    t.virtual "applicant_last_name", type: :citext, as: "(submitted_application #>> '{client_details,applicant,last_name}'::text[])", stored: true
    t.string "offence_class"
    t.index ["applicant_last_name", "applicant_first_name"], name: "index_crime_applications_on_applicant_name"
    t.index ["reference"], name: "index_crime_applications_on_reference"
    t.index ["review_status", "reviewed_at"], name: "index_crime_applications_on_review_status_and_reviewed_at"
    t.index ["review_status", "submitted_at"], name: "index_crime_applications_on_review_status_and_submitted_at"
    t.index ["searchable_text"], name: "index_crime_applications_on_searchable_text", using: :gin
    t.index ["status", "returned_at"], name: "index_crime_applications_on_status_and_returned_at", order: { returned_at: :desc }
    t.index ["status", "reviewed_at"], name: "index_crime_applications_on_status_and_reviewed_at", order: { reviewed_at: :desc }
    t.index ["status", "submitted_at"], name: "index_crime_applications_on_status_and_submitted_at", order: { submitted_at: :desc }
  end

  create_table "personally_identifiable_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id"
    t.jsonb "protected_details", default: {}, null: false
    t.index ["crime_application_id"], name: "index_personally_identifiable_details_on_crime_application_id", unique: true
  end

  create_table "return_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reason", null: false
    t.text "details"
    t.uuid "crime_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crime_application_id"], name: "index_return_details_on_crime_application_id"
  end

  add_foreign_key "personally_identifiable_details", "crime_applications"
  add_foreign_key "return_details", "crime_applications"
end
