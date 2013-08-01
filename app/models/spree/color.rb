class Spree::Color < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :color_matches
	has_many :boards, :through => :color_matches 
	belongs_to :color_collection
	
	attr_accessible :name

end