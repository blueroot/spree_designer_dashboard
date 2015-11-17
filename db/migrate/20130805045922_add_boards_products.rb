class AddBoardsProducts < ActiveRecord::Migration
  def up
    create_table :spree_board_products, :force => true do |t|
      t.column :board_id, :integer
      t.column :product_id, :integer
      t.column :top_left_x, :integer
      t.column :top_left_y, :integer
      t.column :z_index, :integer
      t.column :status, :string, :default => "active"
      t.column :width, :integer
      t.column :height, :integer
      
      
      
      
      
      t.timestamps
    end
  end

  def down
  end
end