class RemoveProfilesDateOfBirth < ActiveRecord::Migration
  def up
    remove_column :profiles, :date_of_birth
  end

  def down
    add_column :profiles, :date_of_birth, :date
  end
end
