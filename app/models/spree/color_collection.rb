class Spree::ColorCollection < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :colors
  
  attr_accessible :name
end