class Spree::BoardProduct < ActiveRecord::Base
  
  belongs_to :board
  belongs_to :product	
	attr_accessible :board_id, :product_id, :top_left_x, :top_left_y, :z_index, :status, :width, :height, :rotation_offset
  before_create :set_z_index
  default_scope  { where("#{Spree::BoardProduct.quoted_table_name}.deleted_at IS NULL or #{Spree::BoardProduct.quoted_table_name}.deleted_at >= ?", Time.zone.now) }
  
  def self.by_supplier(supplier_id)
    includes(:product).where("products.supplier_id = #{supplier_id}").references(:product)
  end
  
  def set_z_index
    self.z_index = self.board.board_products.size
  end
  
  def destroy
    board = self.board
    self.update_attribute('deleted_at', Time.zone.now)
    if board
      board.board_products.reload
      board.queue_image_generation
    end
  end
  
  def self.marked_removal
    where(:status => ["rejected", "marked_for_deletion"])
  end
  
  def self.marked_approval
    where(:status => ["approved"])
  end
  
  def self.pending_approval
    includes(:product).where("isnull(spree_products.deleted_at) and isnull(spree_board_products.approved_at) and isnull(spree_board_products.removed_at)")
  end
  
end