class Spree::Board < ActiveRecord::Base
  validates_presence_of :name, :description
  
  has_many :products
	belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
	has_many :color_matches
	has_many :colors, :through => :color_matches
	
	attr_accessible :name, :description

end