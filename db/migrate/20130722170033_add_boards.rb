class AddBoards < ActiveRecord::Migration
  def up
    create_table :spree_boards, :force => true do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :designer_id, :integer
      t.column :image_url, :string
      
      
      t.timestamps
    end
    
    create_table :spree_colors, :force => true do |t|
      t.column :name, :string
      t.column :hex_val, :string
      t.column :rgb_val, :string
      t.column :swatch_val, :string
      t.column :color_collection_id, :integer
      t.timestamps
    end
    
    create_table :spree_color_matches, :force => true do |t|
      t.column :board_id, :integer
      t.column :color_id, :integer
      
      t.timestamps
    end
    
    create_table :spree_color_collections, :force => true do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :vendor_name, :string
      t.column :url, :string
      t.timestamps
    end
    
    add_column :spree_products, :board_id, :integer
    
    
    
  end

  def down
  end
end