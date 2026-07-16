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

ActiveRecord::Schema[8.1].define(version: 2026_07_15_143422) do
  create_table "bookings", force: :cascade do |t|
    t.string "car_model"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "customer_phone"
    t.date "date"
    t.integer "service_id", null: false
    t.string "slot"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "wash_id", null: false
    t.index ["code"], name: "index_bookings_on_code", unique: true
    t.index ["customer_phone"], name: "index_bookings_on_customer_phone"
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.index ["wash_id", "date", "slot"], name: "index_bookings_on_wash_id_and_date_and_slot"
    t.index ["wash_id"], name: "index_bookings_on_wash_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "booking_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.integer "wash_id", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["wash_id"], name: "index_reviews_on_wash_id"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes"
    t.string "name"
    t.integer "price"
    t.datetime "updated_at", null: false
    t.integer "wash_id", null: false
    t.index ["wash_id"], name: "index_services_on_wash_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "wash_id"
    t.index ["wash_id"], name: "index_users_on_wash_id"
  end

  create_table "washes", force: :cascade do |t|
    t.string "address"
    t.integer "bays", default: 2
    t.integer "close_hour", default: 22
    t.datetime "created_at", null: false
    t.text "description"
    t.string "district"
    t.boolean "featured", default: false
    t.string "name"
    t.integer "open_hour", default: 8
    t.string "phone"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["district"], name: "index_washes_on_district"
    t.index ["slug"], name: "index_washes_on_slug", unique: true
  end

  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "washes"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "washes"
  add_foreign_key "services", "washes"
  add_foreign_key "users", "washes"
end
