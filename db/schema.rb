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

ActiveRecord::Schema[8.1].define(version: 2026_01_04_140251) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "color_palettes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "display_order", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order"], name: "index_color_palettes_on_display_order", unique: true
  end

  create_table "color_themes", force: :cascade do |t|
    t.string "color_code", null: false
    t.string "color_name", null: false
    t.integer "color_palette_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "display_order", null: false
    t.boolean "is_active", default: true, null: false
    t.integer "palette_id"
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
    t.bigint "user_id", null: false
    t.index ["color_theme_id"], name: "index_daily_themes_on_color_theme_id"
    t.index ["user_id", "theme_date"], name: "index_daily_themes_on_user_id_and_theme_date", unique: true
    t.index ["user_id"], name: "index_daily_themes_on_user_id"
  end

  create_table "palette_progresses", force: :cascade do |t|
    t.bigint "color_palette_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "status", default: "locked", null: false
    t.datetime "unlocked_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["color_palette_id"], name: "index_palette_progresses_on_color_palette_id"
    t.index ["user_id", "color_palette_id"], name: "index_palette_progresses_on_user_id_and_color_palette_id", unique: true
    t.index ["user_id"], name: "index_palette_progresses_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "color_theme_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_public", default: false, null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.string "location_name"
    t.decimal "longitude", precision: 10, scale: 7
    t.datetime "posted_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["color_theme_id"], name: "index_posts_on_color_theme_id"
    t.index ["posted_at"], name: "index_posts_on_posted_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "color_themes", "color_palettes"
  add_foreign_key "daily_themes", "color_themes"
  add_foreign_key "daily_themes", "users"
  add_foreign_key "palette_progresses", "color_palettes"
  add_foreign_key "palette_progresses", "users"
  add_foreign_key "posts", "color_themes"
  add_foreign_key "posts", "users"
end
