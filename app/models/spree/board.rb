class Spree::Board < ActiveRecord::Base

  validates_presence_of :name, :description
  
  has_many :board_products
  has_many :products, :through => :board_products
	belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
	has_many :color_matches
	has_many :colors, :through => :color_matches
	
	attr_accessible :name, :description
  

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