class CreatePdfs < ActiveRecord::Migration
  def change
    create_table :pdfs do |t|
      t.string :name
      t.string :url
      t.string :slug
      t.integer :x_offset
      t.integer :y_offset

      t.timestamps
    end
  end
end
