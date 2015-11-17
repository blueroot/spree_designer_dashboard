class Spree::ColorCollection < ActiveRecord::Base
  #attr_accessible :vendor_name, :name, :description
  has_many :colors, :order => :position
end