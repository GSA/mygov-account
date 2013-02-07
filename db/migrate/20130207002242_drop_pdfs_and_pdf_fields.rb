class DropPdfsAndPdfFields < ActiveRecord::Migration
  def up
    drop_table :pdf_fields
    drop_table :pdfs
  end

  def down
    create_table "pdfs", :force => true do |t|
      t.string   "name"
      t.string   "url"
      t.string   "slug"
      t.integer  "x_offset",    :default => 0
      t.integer  "y_offset",    :default => 0
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
      t.boolean  "is_fillable"
    end
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
  end
end
