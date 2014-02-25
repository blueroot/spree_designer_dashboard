class Spree::Board < ActiveRecord::Base

  validates_presence_of :name
  
  has_many :board_products, :order => "z_index"
  has_many :products, :through => :board_products
	belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
	has_many :color_matches
	has_many :colors, :through => :color_matches
	has_many :messages
	
	belongs_to :room, :foreign_key => "room_id", :class_name => "Spree::Taxon"
	belongs_to :style, :foreign_key => "style_id", :class_name => "Spree::Taxon"
	
	attr_accessible :name, :description, :style_id, :room_id, :status, :message, :featured, :featured_starts_at, :featured_expires_at
	
	has_one :board_image, as: :viewable, order: :position, dependent: :destroy, class_name: "Spree::BoardImage"
  attr_accessible :board_image_attributes, :messages_attributes
  accepts_nested_attributes_for :board_image, :messages
  is_impressionable
  
  def self.active
    where(:status => 'published')
  end
  
  def self.featured
    #where(:featured => 1)
    where("featured_starts_at <= ? and featured_expires_at >= ?", Date.today, Date.today)
  end
  
  def room_and_style
    rs = []
    rs << self.room.name if self.room
    rs << self.style.name if self.style
    rs.join(", ")
  end
  
  def display_short_status
    case self.status
      
      when "new"
        "Draft"
      when "submitted_for_publication"
        "Pending"
      when "published"
        "Published"
      when "suspended"
        "Suspended"
      when "deleted"
        "Deleted"
      when "unpublished"
        "Unpublished"
      when "retired"
        "Retired"  
      when "needs_revision"
        "Pending"
      else
        "N/A"
    end
      
  end
  
  def display_status
    case self.status
      
      when "new"
        "Draft - Not Published"
      when "submitted_for_publication"
        "Pending - Submitted for Publication"
      when "published"
        "Published"
      when "suspended"
        "Suspended"
      when "deleted"
        "Deleted"
      when "unpublished"
        "Unpublished"
      when "retired"
        "Retired"  
      when "needs_revision"
        "Pending - Revisions Requested"
      else
        "status not available"
    end
      
  end
  
  def is_dirty?
    self.is_dirty
  end
  
  def self.available_room_taxons
    ["Living Room", "Dining Room", "Bedroom", "Outdoor Living", "Home Office"]
  end
  
  def self.by_style(style_id)
    where(:style_id => style_id)
  end
  
  def self.exclude_self(board_id)
    where("id <> #{board_id}")
  end
  
  def self.by_room(room_id)
    where(:room_id => room_id)
  end
  
  def self.by_color_family(color_family)
    related_colors = Spree::Color.by_color_family(color_family)
    
    includes(:colors).where('spree_colors.id' => related_colors.collect{|color| color.id})
  end
  
  def self.status_options
    [["Draft - Not Published", "new"], ["Pending - Submitted for Publication","submitted_for_publication"], ["Published","published"], ["Suspended","suspended"], ["Deleted","deleted"], ["Unpublished","unpublished"], ["Retired","retired"], ["Pending - Revisions Requested","needs_revision"]]
  end
  
  def self.color_categories
    ["Blue", "Cool Neutral", "Green", "Orange", "Red", "Violet", "Warm Neutral", "White", "Yellow"]
  end
  
  scope :by_color, (lambda do |color|
    joins(:color_matches).where('spree_color_matches.color_id = ?', color.id) unless color.nil?
  end)
  
  def self.by_designer(designer_id)
    where(:designer_id => designer_id)
  end
  
  def self.by_lower_bound_price(price)
    includes(:products).where('spree_products.id' => Spree::Product.master_price_gte(price).collect{|color| color.id})
    #includes(:products).where('spree_products.master_price > ?', price)
    #joins(:products).merge(Spree::Product.master_price_gte(price))
  end
  
  def self.by_upper_bound_price(price)
    includes(:products).where('spree_products.id' => Spree::Product.master_price_lte(price).collect{|color| color.id})
    #includes(:products).where('spree_products.master_price < ?', price)
    #joins(:products).merge(Spree::Product.master_price_lte(price))
  end
  
  def related_boards
    
    boards_scope = Spree::Board.active
    boards_scope = boards_scope.exclude_self(self.id)
    
    #unless self.color_family.blank?
    #  #@boards_scope = @boards_scope.by_color_family(self.color_family)
    #end
    
    unless self.room_id.blank?
      boards_scope = boards_scope.by_room(self.room_id)
    end
    
    unless self.style_id.blank?
      boards_scope = boards_scope.by_style(self.style_id)
    end
    
    boards_scope
    
  end
  
  def queue_image_generation
    # the board is marked as dirty whenever it is added to the delayed job queue.  That way we don't have to make countless updates but instead can just queue them all up
    # so skip this if it is already dirty...that means it has already been added to the queue
    unless self.is_dirty?
      self.update_attribute("is_dirty",1)
      self.delay(run_at: 3.seconds.from_now).generate_image
      #self.generate_image
    end
  end
  
  def generate_image
    white_canvas = Magick::Image.new(630,360){ self.background_color = "white" }
    self.board_products(:order => "z_index asc").reload.collect

    self.board_products.each do |bp|
      top_left_x, top_left_y = bp.top_left_x, bp.top_left_y
      product_image = bp.product.image_for_board
      if bp.rotation_offset and bp.rotation_offset > 0
        
        # set the rotation
        product_image.rotate!(bp.rotation_offset)

        # if turned sideways, then swap the width and height when scaling
        if [90,270].include?(bp.rotation_offset)
          product_image.scale!(bp.height, bp.width)
          centerX = bp.top_left_x + bp.width/2
          centerY = bp.top_left_y + bp.height/2
          top_left_x = centerX - bp.height/2
          top_left_y = centerY - bp.width/2
            
        # original width and height work if it is just rotated 180  
        else
          product_image.rotate!(bp.rotation_offset)
          product_image.scale!(bp.width, bp.height)
        end
      else
        product_image.scale!(bp.width, bp.height)
      end
    	
    	white_canvas.composite!(product_image, Magick::NorthWestGravity, top_left_x, top_left_y, Magick::OverCompositeOp)
    end
    white_canvas.format = 'jpeg'
    file = Tempfile.new("room_#{self.id}.jpg")
    white_canvas.write(file.path)
    self.build_board_image if self.board_image.blank?
    self.board_image.attachment = file      
    
    # set it to be clean again 
    self.is_dirty = 0
    self.save
  end

end