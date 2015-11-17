class AddIsDesignerToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :is_designer, :boolean, :default => 0
  end
end
