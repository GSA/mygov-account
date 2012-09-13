class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.integer :x
      t.integer :y

      t.timestamps
    end
  end
end
