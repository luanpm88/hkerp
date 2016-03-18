# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140324084629) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents_contacts", force: true do |t|
    t.integer  "agent_id"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tmpcat"
    t.integer  "level"
  end

  create_table "categories_products", id: false, force: true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "contact_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "mobile"
    t.string   "fax"
    t.string   "email"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tax_code"
    t.text     "note"
    t.integer  "contact_type_id"
    t.string   "website"
    t.string   "account_number"
    t.string   "bank"
    t.string   "representative"
    t.string   "representative_role"
    t.string   "representative_phone"
    t.boolean  "is_mine",              default: false
    t.string   "hotline"
    t.integer  "user_id"
  end

  create_table "manufacturers", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tmpmenu"
  end

  create_table "order_details", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "price",               precision: 16, scale: 2
    t.decimal  "supplier_price",      precision: 16, scale: 2
    t.string   "product_name"
    t.integer  "warranty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unit"
    t.integer  "supplier_id"
    t.string   "product_description"
  end

  create_table "orders", force: true do |t|
    t.integer  "customer_id"
    t.integer  "supplier_id"
    t.integer  "agent_id"
    t.string   "shipping_place"
    t.integer  "payment_method_id"
    t.datetime "payment_deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "buyer_name"
    t.string   "buyer_company"
    t.string   "buyer_tax_code"
    t.string   "buyer_address"
    t.string   "buyer_email"
    t.string   "buyer_phone"
    t.string   "buyer_fax"
    t.integer  "tax_id"
    t.datetime "order_date"
    t.datetime "order_deadline"
    t.string   "quotation_code",    default: "HK-0000-000"
    t.integer  "salesperson_id"
    t.integer  "deposit"
    t.datetime "shipping_date"
    t.string   "shipping_time"
    t.string   "warranty_place"
    t.text     "warranty_cost"
    t.integer  "older_id"
  end

  create_table "parent_categories", force: true do |t|
    t.integer "category_id"
    t.integer "parent_id"
  end

  create_table "parent_contacts", force: true do |t|
    t.integer "contact_id"
    t.integer "parent_id"
  end

  create_table "payment_methods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "price",           precision: 16, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "product_code"
    t.string   "warranty"
    t.integer  "manufacturer_id"
    t.string   "unit"
    t.integer  "user_id"
    t.integer  "tmpproduct"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxes", force: true do |t|
    t.string   "name"
    t.decimal  "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tmpcats", force: true do |t|
    t.text "category_id"
    t.text "category_image"
    t.text "category_parent_id"
    t.text "category_publish"
    t.text "category_ordertype"
    t.text "category_template"
    t.text "category_ordering"
    t.text "category_add_date"
    t.text "products_page"
    t.text "products_row"
    t.text "name_en_GB"
    t.text "alias_en_GB"
    t.text "short_description_en_GB"
    t.text "description_en_GB"
    t.text "meta_title_en_GB"
    t.text "meta_description_en_GB"
    t.text "meta_keyword_en_GB"
    t.text "name_vi_VN"
    t.text "alias_vi_VN"
    t.text "short_description_vi_VN"
    t.text "description_vi_VN"
    t.text "meta_title_vi_VN"
    t.text "meta_description_vi_VN"
    t.text "meta_keyword_vi_VN"
  end

  create_table "tmpmanus", force: true do |t|
    t.text     "manufacturer_id"
    t.text     "manufacturer_url"
    t.text     "manufacturer_logo"
    t.text     "manufacturer_publish"
    t.text     "products_page"
    t.text     "products_row"
    t.text     "ordering"
    t.text     "name_en_gb"
    t.text     "alias_en_gb"
    t.text     "short_description_en_gb"
    t.text     "description_en_gb"
    t.text     "meta_title_en_gb"
    t.text     "meta_description_en_gb"
    t.text     "meta_keyword_en_gb"
    t.text     "name_vi_vn"
    t.text     "alias_vi_vn"
    t.text     "short_description_vi_vn"
    t.text     "description_vi_vn"
    t.text     "meta_title_vi_vn"
    t.text     "meta_description_vi_vn"
    t.text     "meta_keyword_vi_vn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tmpproducts", force: true do |t|
    t.text     "product_id"
    t.text     "product_ean"
    t.text     "product_quantity"
    t.text     "unlimited"
    t.text     "product_availability"
    t.text     "product_date_added"
    t.text     "date_modify"
    t.text     "product_publish"
    t.text     "product_tax_id"
    t.text     "product_template"
    t.text     "product_url"
    t.text     "product_old_price"
    t.text     "product_buy_price"
    t.text     "product_price"
    t.text     "min_price"
    t.text     "different_prices"
    t.text     "product_weight"
    t.text     "product_thumb_image"
    t.text     "product_name_image"
    t.text     "product_full_image"
    t.text     "product_manufacturer_id"
    t.text     "product_is_add_price"
    t.text     "average_rating"
    t.text     "reviews_count"
    t.text     "delivery_times_id"
    t.text     "hits"
    t.text     "weight_volume_units"
    t.text     "basic_price_unit_id"
    t.text     "label_id"
    t.text     "vendor_id"
    t.text     "name_en_gb"
    t.text     "alias_en_gb"
    t.text     "short_description_en_gb"
    t.text     "description_en_gb"
    t.text     "meta_title_en_gb"
    t.text     "meta_description_en_gb"
    t.text     "meta_keyword_en_gb"
    t.text     "product_warranty"
    t.text     "name_vi_vn"
    t.text     "alias_vi_vn"
    t.text     "short_description_vi_vn"
    t.text     "description_vi_vn"
    t.text     "meta_title_vi_vn"
    t.text     "meta_description_vi_vn"
    t.text     "meta_keyword_vi_vn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tmpproducttocats", force: true do |t|
    t.text     "product_id"
    t.text     "category_id"
    t.text     "product_ordering"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_ext"
    t.string   "mobile"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
