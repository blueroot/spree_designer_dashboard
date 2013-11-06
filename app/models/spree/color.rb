class Spree::Color < ActiveRecord::Base
  has_many :color_matches
	has_many :boards, :through => :color_matches 
	belongs_to :color_collection
  attr_accessible :swatch_val, :name, :hex_val, :position, :cmyk_c, :cmyk_m, :cmyk_y, :cmyk_k, :rgb_r, :rgb_g, :rgb_b, :lrv_x, :lrv_y, :lrv_z, :lstar, :bstart, :astar, :cstar, :hab, :munsell_hue, :munsell_value, :munsell_chroma, :sw_instrument, :sw_illuminant, :sw_observer, :color_collection_id, :hsv_h, :hsv_s, :hsv_v, :lrv, :color_family

  def self.by_color_family(color_family)
    where(:color_family => color_family)
  end

  def self.red
    where(color_family: 'red')
  end
  
  def self.blue
    where(color_family: 'Blue')
  end
  
  def self.cool_neutral
    where(color_family: 'Cool Neutral')
  end
  
  def self.green
    where(color_family: 'Green')
  end
  
  def self.orange
    where(color_family: 'Orange')
  end
  
  def self.violet
    where(color_family: 'Violet')
  end
  
  def self.warm_neutral
    where(color_family: 'Warm Neutral')
  end
  
  def self.white
    where(color_family: 'White')
  end
  
  def self.yellow
    where(color_family: 'Yellow')
  end

end