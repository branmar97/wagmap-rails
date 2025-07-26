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

ActiveRecord::Schema[7.2].define(version: 2025_07_26_212552) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "breeds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.bigint "primary_breed_id", null: false
    t.bigint "secondary_breed_id", null: false
    t.bigint "user_id", null: false
    t.date "birthdate"
    t.string "sex"
    t.text "description"
    t.boolean "health"
    t.string "colors", default: [], array: true
    t.string "compatibilities", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["primary_breed_id"], name: "index_pets_on_primary_breed_id"
    t.index ["secondary_breed_id"], name: "index_pets_on_secondary_breed_id"
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "pets", "breeds", column: "primary_breed_id"
  add_foreign_key "pets", "breeds", column: "secondary_breed_id"
  add_foreign_key "pets", "users"
end
