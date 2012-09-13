class AddPdfIdToPdfFields < ActiveRecord::Migration
  def change
    add_column :pdf_fields, :pdf_id, :integer
    add_index :pdf_fields, :pdf_id
  end
end
