class AddIsApprovedToBetaSignups < ActiveRecord::Migration
  def change
    add_column :beta_signups, :is_approved, :boolean, :default => false
  end
end
