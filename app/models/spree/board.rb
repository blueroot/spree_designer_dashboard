class Spree::Board < ActiveRecord::Base
  #include AASM

  state_machine :state, :initial => :new do
    
    after_transition :on => [:publish, :request_designer_revision], :do => :remove_marked_products
    
    event :submit_for_publication do
      transition :new => :submitted_for_publication, :in_revision => :submitted_for_publication
    end
    
    event :request_designer_revision do
      transition all => :in_revision
    end
    
    event :publish do
      transition all => :published
    end
    
    event :suspend do
      transition all => :suspended
    end
    
    event :delete do
      transition all => :deleted
    end
    
    state :new, :in_revision, :submitted_for_publication do
      def draft?
        true
      end
    end
    
    state :published do 
      def published?
        true
      end
    end
  end

  def remove_marked_products
    delete_removed_board_products
    delete_deleted_board_products
    self.generate_image
  end
  
  #aasm column: :state, whiny_transitions: true do
  #
  #  state :draft, initial: true
  #  state :suspended_for_inactivity
  #  state :submitted_for_publication
  #  state :deleted
  #  state :published
  #  state :unpublished
  #
  #  event :request_revision, before: :process_revision_request do
  #    transitions from: [:submitted_for_publication, :published, :draft, :suspended_for_inactivity, :unpublished], to: :draft
  #  end
  #
  #  event :submit_for_publication, before: :update_submitted_for_publication_status do
  #    transitions from: [:draft, :suspended_for_inactivity, :published, :unpublished], to: :submitted_for_publication
  #  end
  #
  #  event :delete_permanently, before: :handle_deletion do
  #    transitions from: [:submitted_for_publication, :draft, :suspended_for_inactivity, :published, :unpublished], to: :deleted
  #  end
  #
  #  event :publish, before: :handle_publication do
  #    transitions from: [:submitted_for_publication, :draft, :published], to: :published
  #  end
  #
  #end

  #def handle_publication
  #  self.update_attributes!({status: "published"}, without_protection: true )
  #  delete_removed_board_products
  #  delete_marked_products
  #end

  def handle_deletion
    #self.update_attributes!({status: "deleted"}, without_protection: true )
    #delete_removed_board_products
    #delete_marked_products
    #self.destroy
  end

  def delete_removed_board_products
    self.board_products.marked_removal.each(&:destroy)
  end
  
  def delete_deleted_board_products
    self.board_products.marked_deletion.collect(&:product).compact.each(&:destroy)
    self.board_products.marked_deletion.each(&:destroy)
  end
  
  def update_submitted_for_publication_status
    self.update_attributes!({status: "submitted_for_publication"}, without_protection: true )
  end

  def process_revision_request    
    self.update_attributes!({current_state_label: "needs revision", status: "needs_revision"}, without_protection: true)
    delete_removed_board_products
    delete_marked_products
  end

  def remove_all_products
    self.board_products.each(&:destroy!)
  end

  validates_presence_of :name

  has_many :board_products, :order => "z_index", dependent: :destroy
  has_many :products, :through => :board_products
  belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
  has_many :color_matches
  has_many :colors, :through => :color_matches
  has_many :messages

  belongs_to :room, :foreign_key => "room_id", :class_name => "Spree::Taxon"
  belongs_to :style, :foreign_key => "style_id", :class_name => "Spree::Taxon"

  has_one :board_image, as: :viewable, order: :position, dependent: :destroy, class_name: "Spree::BoardImage"
  #attr_accessible :board_image_attributes, :messages_attributes
  accepts_nested_attributes_for :board_image, :messages
  is_impressionable

  after_save :update_product_publish_status

  default_scope  { where("#{Spree::Board.quoted_table_name}.deleted_at IS NULL or #{Spree::Board.quoted_table_name}.deleted_at >= ?", Time.zone.now) }


  def update_product_publish_status
    if self.status =="published"
      self.products.update_all(:is_published => 1)
    else
      self.products.each do |product|
        if product.available_sans_board == true
          product.update_attribute("is_published", 1)
        else
          product.update_attribute("is_published", 0)
        end
      end
    end
  end

  # use deleted? rather than checking the attribute directly. this
  # allows extensions to override deleted? if they want to provide
  # their own definition.
  def deleted?
    !!deleted_at
  end

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

  def self.draft
    where(:status => ["new"])
  end

  def self.pending
    where(:status => ["submitted_for_publication", "needs_revision"])
  end

  def self.published
    where(:status => ["published"])
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
      "Draft"
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
    ["Living Room", "Dining Room", "Bedroom", "Outdoor Living", "Home Office", "Kids Room"]
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
    self.board_products(:order => "z_index asc").includes(:product => {:master => [:images]}).reload.collect

    self.board_products.each do |bp|
      top_left_x, top_left_y = bp.top_left_x, bp.top_left_y
      if bp.height == 0
        bp.height = 5
        bp.width = 5 * bp.width
      end
      if bp.width == 0
        bp.width == 5
        bp.height == 5 * bp.height
      end
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
    #self.board_image.destroy if self.board_image
    self.build_board_image if self.board_image.blank?
    #self.board_image.reload
    self.board_image.attachment = file      
    self.board_image.save
    # set it to be clean again 
    self.is_dirty = 0
    self.save
  end

  def destroy
    self.update_attribute('deleted_at', Time.zone.now)
    self.board_products.destroy_all
  end

  def designer_name
    "#{self.designer.first_name} #{self.designer.last_name}"
  end

  def coded_designer_name
    "#{self.designer.first_name.downcase}_#{self.designer.last_name.downcase}"
  end
  
  def to_url
    "https://scoutandnimble.com/rooms/#{self.id}"
  end
  
  def send_publication_email(message_content="")
    
    html_content = "Hi #{self.designer.full_name}, <br />Your room <strong>#{self.name}</strong> has been approved and published.  You can <a href=\"#{self.to_url}\">visit your room here</a> to check it out."
    
    m = Mandrill::API.new(MANDRILL_KEY)
    message = {
      :subject=> "Your room has been approved!",
      :from_name=> "Scout & Nimble",
      :text=>"#{message_content} \n\n The Scout & Nimble Team",
      :to=>[
       {
         :email=> self.designer.email,
         :name=> self.designer.full_name
       }
       ],
       :from_email=>"designer@scoutandnimble.com",
       :track_opens => true,
       :track_clicks => true,
       :url_strip_qs => false,
       :signing_domain => "scoutandnimble.com"
     }

     sending = m.messages.send_template('simple-template', [{:name => 'main', :content => html_content}, {:name => 'extra-message', :content => message_content}], message, true)

     logger.info sending   
  end
  
  def send_revision_request_email(message_content="")
    
    html_content = "Hi #{self.designer.full_name}, <br /> Your room, \"#{self.name}\" has been reviewed and needs revision before publishing.  Please visit the <a href=\"#{self.to_url}/design\">design page</a> to make any revisions. "
    
    m = Mandrill::API.new(MANDRILL_KEY)
    message = {
      :subject=> "Your room status has changed: needs revision",
      :from_name=> "Scout & Nimble",
      :text=>"#{message_content} \n\n The Scout & Nimble Team",
      :to=>[
       {
         :email=> self.designer.email,
         :name=> self.designer.full_name
       }
       ],
       :from_email=>"designer@scoutandnimble.com",
       :track_opens => true,
       :track_clicks => true,
       :url_strip_qs => false,
       :signing_domain => "scoutandnimble.com"
     }

     sending = m.messages.send_template('simple-template', [{:name => 'main', :content => html_content}, {:name => 'extra-message', :content => message_content}], message, true)

     logger.info sending   
  end
  

end
