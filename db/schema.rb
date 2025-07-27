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

ActiveRecord::Schema[7.2].define(version: 2025_07_27_124147) do
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

  create_table "spaces", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address1", limit: 255, null: false
    t.string "address2", limit: 255
    t.string "city", limit: 100, null: false
    t.string "state", limit: 2, null: false
    t.string "zipcode", limit: 10, null: false
    t.string "fencing_status", null: false
    t.string "space_size", limit: 100, null: false
    t.integer "max_dogs_per_booking", null: false
    t.decimal "price_per_dog", precision: 8, scale: 2, null: false
    t.boolean "other_dogs_visible_audible"
    t.boolean "other_pets_visible_audible"
    t.boolean "other_people_visible_audible"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "state"], name: "index_spaces_on_city_and_state"
    t.index ["status"], name: "index_spaces_on_status"
    t.index ["user_id"], name: "index_spaces_on_user_id"
    t.check_constraint "fencing_status::text = ANY (ARRAY['fully_fenced'::character varying, 'partially_fenced'::character varying, 'not_fenced'::character varying]::text[])", name: "fencing_status_check"
    t.check_constraint "max_dogs_per_booking >= 1 AND max_dogs_per_booking <= 50", name: "max_dogs_range_check"
    t.check_constraint "price_per_dog > 0::numeric", name: "price_positive_check"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])", name: "status_check"
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
  add_foreign_key "spaces", "users"
end
