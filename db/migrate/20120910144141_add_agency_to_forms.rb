class AddAgencyToForms < ActiveRecord::Migration
  def change
    add_column :forms, :agency, :string
  end
end
