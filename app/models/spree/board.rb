class Spree::Board < ActiveRecord::Base

  validates_presence_of :name
  
  has_many :board_products
  has_many :products, :through => :board_products
	belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
	has_many :color_matches
	has_many :colors, :through => :color_matches
	
	belongs_to :room, :foreign_key => "room_id", :class_name => "Spree::Taxon"
	belongs_to :style, :foreign_key => "style_id", :class_name => "Spree::Taxon"
	
	attr_accessible :name, :description, :style_id, :room_id
	
	has_one :board_image, as: :viewable, order: :position, dependent: :destroy, class_name: "Spree::BoardImage"
  attr_accessible :board_image_attributes
  accepts_nested_attributes_for :board_image
  
  def self.active
    where(:status => 'active')
  end
  
  def self.by_style(style_id)
    where(:style_id => style_id)
  end
  
  def self.by_room(room_id)
    where(:room_id => room_id)
  end
  
  scope :by_color, (lambda do |color|
    joins(:color_matches).where('spree_color_matches.color_id = ?', color.id) unless color.nil?
  end)
  
  def self.by_designer(designer_id)
    where(:designer_id => designer.id)
  end
  scope :by_lower_bound_price, (lambda do |price|
    #joins(:products).merge(Spree::Product.master_price_gte(price))
  end)
  #
  #scope :by_upper_bound_price, (lambda do |price|
  #  joins(:products).where('spree_products.price < ?', price) unless price.nil?
  #end)
  
  
  #def render_board
  #  white_canvas = Image.new(720,400){ self.background_color = "white" }
  #  self.board_products.reload
  #  self.board_products.each do |bp|
  #  	product_image = ImageList.new(bp.product.images.first.attachment.url(:product))
  #  	product_image.scale!(bp.width, bp.height)
  #  	white_canvas.composite!(product_image, NorthWestGravity, bp.top_left_x, bp.top_left_y, Magick::OverCompositeOp)
  #  end
  #  white_canvas.format = 'jpeg'
  #  white_canvas.write("#{Rails.root}/boards/#{b.id}.jpg")
  #end
end