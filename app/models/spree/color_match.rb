class Spree::ColorMatch < ActiveRecord::Base
  belongs_to :board
	belongs_to :color
end