class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :body
      t.timestamp :received_at
      t.references :o_auth2_model_client
      t.references :user

      t.timestamps
    end
    add_index :messages, :o_auth2_model_client_id
    add_index :messages, :user_id
  end
end
