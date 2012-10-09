class CreateUsHolidays < ActiveRecord::Migration
  def change
    create_table :us_holidays do |t|
      t.string :name
      t.date :observed_on
      t.string :uid

      t.timestamps
    end
    add_index :us_holidays, :observed_on
    add_index :us_holidays, :uid
  end
end
