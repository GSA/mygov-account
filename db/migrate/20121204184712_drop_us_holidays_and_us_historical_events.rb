class DropUsHolidaysAndUsHistoricalEvents < ActiveRecord::Migration
  def up
    drop_table :us_holidays
    drop_table :us_historical_events
  end

  def down
    create_table "us_holidays", :force => true do |t|
      t.string   "name"
      t.date     "observed_on"
      t.string   "uid"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end
    add_index "us_holidays", ["observed_on"], :name => "index_us_holidays_on_observed_on"
    add_index "us_holidays", ["uid"], :name => "index_us_holidays_on_uid"
    
    create_table "us_historical_events", :force => true do |t|
      t.string   "summary"
      t.string   "uid"
      t.integer  "day"
      t.integer  "month"
      t.string   "categories"
      t.string   "location"
      t.string   "description"
      t.string   "url"
      t.string   "event_type"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end
    add_index "us_historical_events", ["day", "month"], :name => "index_us_historical_events_on_day_and_month"
  end
end
