class AddActionPhraseToApps < ActiveRecord::Migration
  def change
    add_column :apps, :action_phrase, :string
  end
end
