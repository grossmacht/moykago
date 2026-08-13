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

ActiveRecord::Schema[8.1].define(version: 2026_08_13_112104) do
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

  create_table "bookings", force: :cascade do |t|
    t.integer "amount_charged"
    t.integer "car_id"
    t.string "car_model"
    t.string "code"
    t.integer "commission_amount"
    t.decimal "commission_rate", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.integer "customer_id"
    t.string "customer_name"
    t.string "customer_phone"
    t.date "date"
    t.integer "discount_amount"
    t.integer "payment_method"
    t.integer "promo_code_id"
    t.integer "service_id", null: false
    t.string "slot"
    t.integer "status", default: 0, null: false
    t.bigint "telegram_chat_id"
    t.datetime "updated_at", null: false
    t.integer "wash_id", null: false
    t.index ["car_id"], name: "index_bookings_on_car_id"
    t.index ["code"], name: "index_bookings_on_code", unique: true
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["customer_phone"], name: "index_bookings_on_customer_phone"
    t.index ["promo_code_id"], name: "index_bookings_on_promo_code_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.index ["telegram_chat_id"], name: "index_bookings_on_telegram_chat_id"
    t.index ["wash_id", "date", "slot"], name: "index_bookings_on_wash_id_and_date_and_slot"
    t.index ["wash_id"], name: "index_bookings_on_wash_id"
  end

  create_table "bot_sessions", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.text "payload"
    t.string "step", default: "idle", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_bot_sessions_on_chat_id", unique: true
  end

  create_table "cars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "make"
    t.string "model"
    t.string "plate"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_cars_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.integer "bonus_balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.boolean "referral_bonus_granted", default: false, null: false
    t.string "referral_code"
    t.bigint "referred_by_id"
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_customers_on_phone", unique: true
    t.index ["referral_code"], name: "index_customers_on_referral_code", unique: true
    t.index ["referred_by_id"], name: "index_customers_on_referred_by_id"
  end

  create_table "promo_codes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "discount_type", default: 0, null: false
    t.datetime "expires_at"
    t.integer "min_amount"
    t.datetime "updated_at", null: false
    t.integer "usage_limit"
    t.integer "used_count", default: 0, null: false
    t.integer "value", null: false
    t.index ["code"], name: "index_promo_codes_on_code", unique: true
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
    t.decimal "commission_rate", precision: 5, scale: 2, default: "15.0", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "cars"
  add_foreign_key "bookings", "customers"
  add_foreign_key "bookings", "promo_codes"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "washes"
  add_foreign_key "cars", "customers"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "washes"
  add_foreign_key "services", "washes"
  add_foreign_key "users", "washes"
end
