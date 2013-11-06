class Spree::ColorMatch < ActiveRecord::Base
  belongs_to :board
	belongs_to :color
	attr_accessible :color_id, :board_id
end