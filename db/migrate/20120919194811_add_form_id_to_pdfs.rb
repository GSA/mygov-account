class AddFormIdToPdfs < ActiveRecord::Migration
  def change
    add_column :pdfs, :form_id, :integer
    add_index :pdfs, :form_id
  end
end
