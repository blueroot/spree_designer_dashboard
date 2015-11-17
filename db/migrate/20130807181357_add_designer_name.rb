class AddDesignerName < ActiveRecord::Migration
  def up
    add_column :spree_users, :first_name, :string
    add_column :spree_users, :last_name, :string
    add_column :spree_users, :company_name, :string
    add_column :spree_users, :website_url, :string
    add_column :spree_users, :location, :string
  end

  def down
  end
end