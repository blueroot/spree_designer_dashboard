class Spree::Board < ActiveRecord::Base

  validates_presence_of :name, :description
  
  has_many :board_products
  has_many :products, :through => :board_products
	belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
	has_many :color_matches
	has_many :colors, :through => :color_matches
	
	attr_accessible :name, :description
	
	has_one :board_image, as: :viewable, order: :position, dependent: :destroy, class_name: "Spree::BoardImage"
  attr_accessible :board_image_attributes
  accepts_nested_attributes_for :board_image
  

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