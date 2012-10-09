class CreateUsHistoricalEvents < ActiveRecord::Migration
  def change
    create_table :us_historical_events do |t|
      t.string :summary
      t.string :uid
      t.integer :day
      t.integer :month
      t.string :categories
      t.string :location
      t.string :description
      t.string :url
      t.string :event_type

      t.timestamps
    end
    add_index :us_historical_events, [:day, :month]
  end
end
