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

ActiveRecord::Schema.define(:version => 20120909005855) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  add_index "apps", ["slug"], :name => "index_apps_on_slug"

  create_table "criteria", :force => true do |t|
    t.string   "label"
    t.integer  "app_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "criteria", ["app_id"], :name => "index_criteria_on_app_id"

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
  end

  add_index "task_items", ["task_id"], :name => "index_task_items_on_task_id"

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.datetime "completed_at"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                              :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "middle_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state",                :limit => 5
    t.string   "zip",                  :limit => 5
    t.date     "date_of_birth"
    t.string   "phone",                :limit => 12
    t.string   "gender",               :limit => 6
    t.string   "marital_status",       :limit => 15
    t.boolean  "is_admin"
    t.string   "title",                :limit => 10
    t.string   "suffix",               :limit => 10
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
