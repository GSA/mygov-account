class AssignDefaultValuesToPdfOffsetFields < ActiveRecord::Migration
  def up
    change_column :pdfs, :x_offset, :integer, :default => 0
    change_column :pdfs, :y_offset, :integer, :default => 0
    change_column :pdf_fields, :x, :integer, :default => 0
    change_column :pdf_fields, :y, :integer, :default => 0
  end

  def down
    change_column :pdfs, :x_offset, :integer
    change_column :pdfs, :y_offset, :integer
    change_column :pdf_fields, :x, :integer
    change_column :pdf_fields, :y, :integer
  end
end
