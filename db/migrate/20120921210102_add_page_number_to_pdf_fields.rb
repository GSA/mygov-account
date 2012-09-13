class AddPageNumberToPdfFields < ActiveRecord::Migration
  def change
    add_column :pdf_fields, :page_number, :integer
  end
end
