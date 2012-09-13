class RenameFieldsToPdfFields < ActiveRecord::Migration
  def up
  	rename_table :fields, :pdf_fields 
  end

  def down
  	rename_table :pdf_fields, :fields
  end
end
