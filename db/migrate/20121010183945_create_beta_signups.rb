class CreateBetaSignups < ActiveRecord::Migration
  def change
    create_table :beta_signups do |t|
      t.string :email
      t.string :ip_address
      t.string :referrer

      t.timestamps
    end
  end
end
