class CreateCriteria < ActiveRecord::Migration
  def change
    create_table :criteria do |t|
      t.string :label
      t.references :app
      t.timestamps
    end
    add_index :criteria, :app_id
  end
end
