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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121011205144) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  add_index "apps", ["slug"], :name => "index_apps_on_slug"

  create_table "beta_signups", :force => true do |t|
    t.string   "email"
    t.string   "ip_address"
    t.string   "referrer"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "is_approved", :default => false
  end

  create_table "criteria", :force => true do |t|
    t.string   "label"
    t.integer  "app_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "criteria", ["app_id"], :name => "index_criteria_on_app_id"

  create_table "criteria_forms", :id => false, :force => true do |t|
    t.integer "criterium_id"
    t.integer "form_id"
  end

  add_index "criteria_forms", ["criterium_id", "form_id"], :name => "index_criteria_forms_on_criterium_id_and_form_id"
  add_index "criteria_forms", ["criterium_id"], :name => "index_criteria_forms_on_criterium_id"
  add_index "criteria_forms", ["form_id"], :name => "index_criteria_forms_on_form_id"

  create_table "forms", :force => true do |t|
    t.string   "url"
    t.string   "name"
    t.string   "call_to_action"
    t.integer  "app_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "agency"
  end

  add_index "forms", ["app_id"], :name => "index_forms_on_app_id"

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.datetime "received_at"
    t.integer  "o_auth2_model_client_id"
    t.integer  "user_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "messages", ["o_auth2_model_client_id"], :name => "index_messages_on_o_auth2_model_client_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "oauth2_authorizations", :force => true do |t|
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "oauth2_resource_owner_type"
    t.integer  "oauth2_resource_owner_id"
    t.integer  "client_id"
    t.string   "scope"
    t.string   "code",                       :limit => 40
    t.string   "access_token_hash",          :limit => 40
    t.string   "refresh_token_hash",         :limit => 40
    t.datetime "expires_at"
  end

  add_index "oauth2_authorizations", ["access_token_hash"], :name => "index_oauth2_authorizations_on_access_token_hash"
  add_index "oauth2_authorizations", ["client_id", "access_token_hash"], :name => "index_oauth2_authorizations_on_client_id_and_access_token_hash"
  add_index "oauth2_authorizations", ["client_id", "code"], :name => "index_oauth2_authorizations_on_client_id_and_code"
  add_index "oauth2_authorizations", ["client_id", "refresh_token_hash"], :name => "index_oauth2_authorizations_on_client_id_and_refresh_token_hash"

  create_table "oauth2_clients", :force => true do |t|
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "oauth2_client_owner_type"
    t.integer  "oauth2_client_owner_id"
    t.string   "name"
    t.string   "client_id"
    t.string   "client_secret_hash"
    t.string   "redirect_uri"
  end

  add_index "oauth2_clients", ["client_id"], :name => "index_oauth2_clients_on_client_id"

  create_table "pdf_fields", :force => true do |t|
    t.string   "name"
    t.integer  "x",                  :default => 0
    t.integer  "y",                  :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "pdf_id"
    t.string   "profile_field_name"
    t.integer  "page_number"
  end

  add_index "pdf_fields", ["pdf_id"], :name => "index_pdf_fields_on_pdf_id"

  create_table "pdfs", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "slug"
    t.integer  "x_offset",    :default => 0
    t.integer  "y_offset",    :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "form_id"
    t.boolean  "is_fillable"
  end

  add_index "pdfs", ["form_id"], :name => "index_pdfs_on_form_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "related_urls", :force => true do |t|
    t.string   "url"
    t.string   "other_url"
    t.integer  "occurence_count", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "related_urls", ["url", "occurence_count"], :name => "index_related_urls_on_url_and_occurence_count"

  create_table "task_items", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "completed_at"
    t.integer  "task_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "form_id"
  end

  add_index "task_items", ["form_id"], :name => "index_task_items_on_form_id"
  add_index "task_items", ["task_id"], :name => "index_task_items_on_task_id"

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.datetime "completed_at"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "app_id"
  end

  add_index "tasks", ["app_id"], :name => "index_tasks_on_app_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "us_historical_events", :force => true do |t|
    t.string   "summary"
    t.string   "uid"
    t.integer  "day"
    t.integer  "month"
    t.string   "categories"
    t.string   "location"
    t.string   "description"
    t.string   "url"
    t.string   "event_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "us_historical_events", ["day", "month"], :name => "index_us_historical_events_on_day_and_month"

  create_table "us_holidays", :force => true do |t|
    t.string   "name"
    t.date     "observed_on"
    t.string   "uid"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "us_holidays", ["observed_on"], :name => "index_us_holidays_on_observed_on"
  add_index "us_holidays", ["uid"], :name => "index_us_holidays_on_uid"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "middle_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state",                  :limit => 5
    t.string   "zip",                    :limit => 5
    t.date     "date_of_birth"
    t.string   "phone",                  :limit => 12
    t.string   "gender",                 :limit => 6
    t.string   "marital_status",         :limit => 15
    t.boolean  "is_admin"
    t.string   "title",                  :limit => 10
    t.string   "suffix",                 :limit => 10
    t.string   "mobile",                 :limit => 12
    t.string   "encrypted_password",                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
