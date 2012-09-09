class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :url
      t.string :name
      t.string :call_to_action
      t.references :app

      t.timestamps
    end
    add_index :forms, :app_id
  end
end
