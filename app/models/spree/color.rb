class Spree::Color < ActiveRecord::Base
  has_many :color_matches
	has_many :boards, :through => :color_matches 
	belongs_to :color_collection
  attr_accessible :swatch_val, :name, :hex_val, :position, :cmyk_c, :cmyk_m, :cmyk_y, :cmyk_k, :rgb_r, :rgb_g, :rgb_b, :lrv_x, :lrv_y, :lrv_z, :lstar, :bstart, :astar, :cstar, :hab, :munsell_hue, :munsell_value, :munsell_chroma, :sw_instrument, :sw_illuminant, :sw_observer, :color_collection_id

end