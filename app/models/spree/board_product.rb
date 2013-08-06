class Spree::BoardProduct < ActiveRecord::Base
  
  belongs_to :board
  belongs_to :product
	
	attr_accessible :board_id, :product_id, :top_left_x, :top_left_y, :z_index, :status, :width, :height

end