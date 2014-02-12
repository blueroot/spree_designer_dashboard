class Spree::BoardProduct < ActiveRecord::Base
  
  belongs_to :board
  belongs_to :product
	
	attr_accessible :board_id, :product_id, :top_left_x, :top_left_y, :z_index, :status, :width, :height, :rotation_offset
  
  before_create :set_z_index
  
  def set_z_index
    self.z_index = self.board.board_products.size
  end
  
  
end