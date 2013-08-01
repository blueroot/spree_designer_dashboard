class Spree::ColorMatch < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :board
	belongs_to :color
	
end