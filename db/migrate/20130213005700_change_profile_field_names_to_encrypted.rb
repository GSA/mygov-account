class ChangeProfileFieldNamesToEncrypted < ActiveRecord::Migration
  def up
    [:first_name, :middle_name, :last_name, :name, :address, :address2, :city, :state, :zip, :phone, :mobile].each do |field|
      rename_column :profiles, field, "encrypted_#{field.to_s}".to_sym
    end
    [:state, :zip, :phone, :mobile].each do |field|
      change_column :profiles, "encrypted_#{field.to_s}".to_sym, :string
    end
  end
  
  def down
    [:first_name, :middle_name, :last_name, :name, :address, :address2, :city, :state, :zip, :phone, :mobile].each{|field| rename_column :profiles, "encrypted_#{field.to_s}".to_sym, field }
  end
end
