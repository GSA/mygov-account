class AddProfileFieldNameToPdfFields < ActiveRecord::Migration
  def change
    add_column :pdf_fields, :profile_field_name, :string
  end
end
