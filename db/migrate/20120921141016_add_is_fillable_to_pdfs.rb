class AddIsFillableToPdfs < ActiveRecord::Migration
  def change
    add_column :pdfs, :is_fillable, :boolean
  end
end
