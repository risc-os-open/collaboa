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

ActiveRecord::Schema[7.2].define(version: 2025_01_17_060029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "changes", id: :serial, force: :cascade do |t|
    t.integer "changeset_id"
    t.integer "revision", default: 0, null: false
    t.string "name", limit: 2, default: "", null: false
    t.text "path", default: "", null: false
    t.text "from_path"
    t.integer "from_revision"
  end

  create_table "changesets", id: :serial, force: :cascade do |t|
    t.integer "revision"
    t.string "author", limit: 50
    t.text "log"
    t.datetime "created_at", precision: nil
    t.datetime "revised_at", precision: nil
  end

  create_table "milestones", id: :serial, force: :cascade do |t|
    t.string "name", limit: 75
    t.text "info"
    t.date "due"
    t.datetime "created_at", precision: nil
    t.integer "completed", default: 0
  end

  create_table "parts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "releases", id: :serial, force: :cascade do |t|
    t.string "name", limit: 25
  end

  create_table "severities", id: :serial, force: :cascade do |t|
    t.integer "position"
    t.string "name", limit: 50
  end

  create_table "status", id: :serial, force: :cascade do |t|
    t.string "name", limit: 25
  end

  create_table "ticket_changes", id: :serial, force: :cascade do |t|
    t.integer "ticket_id"
    t.string "author", limit: 75
    t.text "comment"
    t.datetime "created_at", precision: nil
    t.text "log"
    t.string "attachment", limit: 255
    t.string "content_type", limit: 100
    t.string "attachment_fsname", limit: 255
    t.text "author_email"
  end

  create_table "tickets", id: :serial, force: :cascade do |t|
    t.integer "milestone_id", default: 0
    t.integer "part_id", default: 0
    t.integer "severity_id", default: 0, null: false
    t.integer "release_id"
    t.integer "status_id", default: 1, null: false
    t.string "author", limit: 75
    t.string "summary", limit: 255
    t.text "content"
    t.string "author_host", limit: 100
    t.datetime "created_at", precision: nil
    t.text "author_email"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login", limit: 80
    t.string "password", limit: 40
    t.datetime "created_at", precision: nil
    t.boolean "view_changesets", default: true
    t.boolean "view_code", default: true
    t.boolean "view_tickets", default: true
    t.boolean "create_tickets", default: true
    t.boolean "admin", default: false
    t.boolean "view_milestones", default: true
  end
end
