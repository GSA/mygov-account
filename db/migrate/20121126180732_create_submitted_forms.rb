class CreateSubmittedForms < ActiveRecord::Migration
  def change
    create_table :submitted_forms do |t|
      t.references :user
      t.references :app
      t.string :form_number
      t.string :data_url

      t.timestamps
    end
    add_index :submitted_forms, :user_id
    add_index :submitted_forms, :app_id
  end
end
