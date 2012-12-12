class DropActionPhraseFromApps < ActiveRecord::Migration
  def up
    remove_column :apps, :action_phrase
  end

  def down
    add_column :apps, :action_phrase, :string
  end
end
