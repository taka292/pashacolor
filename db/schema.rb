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

ActiveRecord::Schema[8.1].define(version: 2025_12_30_101306) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "color_themes", force: :cascade do |t|
    t.string "color_code", null: false
    t.string "color_name", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "display_order", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["display_order"], name: "index_color_themes_on_display_order"
    t.index ["is_active"], name: "index_color_themes_on_is_active"
  end

  create_table "daily_themes", force: :cascade do |t|
    t.bigint "color_theme_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "theme_date", null: false
    t.datetime "updated_at", null: false
    t.index ["color_theme_id"], name: "index_daily_themes_on_color_theme_id"
    t.index ["theme_date"], name: "index_daily_themes_on_theme_date", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "daily_themes", "color_themes"
end
