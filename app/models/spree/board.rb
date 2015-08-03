class Spree::Board < ActiveRecord::Base


  belongs_to :designer, :class_name => "User", :foreign_key => "designer_id"
  belongs_to :room, :foreign_key => "room_id", :class_name => "Spree::Taxon"
  belongs_to :style, :foreign_key => "style_id", :class_name => "Spree::Taxon"

  has_many :board_products, :order => "z_index", dependent: :destroy
  has_many :products, :through => :board_products
  has_many :color_matches
  has_many :colors, :through => :color_matches
  has_many :conversations, as: :conversationable, class_name: "::Mailboxer::Conversation"

  has_and_belongs_to_many :promotion_rules,
                          class_name: '::Spree::PromotionRule',
                          join_table: 'spree_boards_promotion_rules',
                          foreign_key: 'board_id'
  has_many :promotions, :through => :promotion_rules

  has_one :board_image, as: :viewable, order: :position, dependent: :destroy, class_name: "Spree::BoardImage"
  has_one :conversation, :class_name => "Mailboxer::Conversation"

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  #friendly_id [:name, :room_style, :room_type], use: :slugged

  def slug_candidates
    [

        [:name, :room_style, :room_type]
    ]
  end

  # state machine audit trail requires that there are fields on the model being audited.  We're creating them virtually since they don't need to be persisted here.
  attr_accessor :state_message
  attr_accessor :transition_user_id

  #attr_accessible :board_image_attributes
  accepts_nested_attributes_for :board_image
  is_impressionable

  validates_presence_of :name

  after_save :update_product_publish_status
  before_save :cache_style_and_room_type

  default_scope { where("#{Spree::Board.quoted_table_name}.deleted_at IS NULL or #{Spree::Board.quoted_table_name}.deleted_at >= ?", Time.zone.now) }

  state_machine :state, :initial => :new do
    store_audit_trail :context_to_log => [:state_message, :transition_user_id]

    after_transition :on => [:publish, :request_designer_revision], :do => :remove_marked_products
    after_transition :on => :publish, :do => :update_state_published

    event :submit_for_publication do
      transition all => :submitted_for_publication, :in_revision => :submitted_for_publication
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

  def update_state_published
    self.update(status: 'published')
  end

  def set_state_transition_context(message, user)
    self.state_message = message
    self.transition_user_id = user.id
  end

  def remove_marked_products
    delete_removed_board_products
    delete_deleted_board_products
    self.queue_image_generation
  end

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
    self.board_products.marked_for_removal.each(&:destroy)
  end

  def delete_deleted_board_products
    self.board_products.marked_for_deletion.collect(&:product).compact.each(&:destroy)
    self.board_products.marked_for_deletion.each(&:destroy)
  end

  def update_submitted_for_publication_status
    self.update_attributes!({status: "submitted_for_publication"}, without_protection: true)
  end

  def process_revision_request
    self.update_attributes!({current_state_label: "needs revision", status: "needs_revision"}, without_protection: true)
    delete_removed_board_products
    delete_marked_products
  end

  def remove_all_products
    self.board_products.each(&:destroy!)
  end

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

  def self.promoted
    includes(promotion_rules: [:promotion]).where("spree_promotions.starts_at <= ? and spree_promotions.expires_at >= ?", Date.today, Date.today)
  end

  def currently_promoted?
    self.current_promotion
  end

  def current_promotion
    p = self.promotions.where("spree_promotions.starts_at <= ? and spree_promotions.expires_at >= ?", Date.today, Date.today)
    p.empty? ? nil : p.first
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
    case self.state

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
      when "in_revision"
        "In Revision"
      else
        "N/A"
    end

  end

  def display_status
    case self.state

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
      when "in_revision"
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

    includes(:colors).where('spree_colors.id' => related_colors.collect { |color| color.id })
  end

  def self.status_options
    [["Draft - Not Published", "new"], ["Pending - Submitted for Publication", "submitted_for_publication"], ["Published", "published"], ["Suspended", "suspended"], ["Deleted", "deleted"], ["Unpublished", "unpublished"], ["Retired", "retired"], ["Pending - Revisions Requested", "needs_revision"]]
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
    includes(:products).where('spree_products.id' => Spree::Product.master_price_gte(price).collect { |color| color.id })
    #includes(:products).where('spree_products.master_price > ?', price)
    #joins(:products).merge(Spree::Product.master_price_gte(price))
  end

  def self.by_upper_bound_price(price)
    includes(:products).where('spree_products.id' => Spree::Product.master_price_lte(price).collect { |color| color.id })
    #includes(:products).where('spree_products.master_price < ?', price)
    #joins(:products).merge(Spree::Product.master_price_lte(price))
  end


  def self.render_taxon_select(taxon, subsubcategory)
    taxon.children.each do |child_taxon|
      subsubcategory << [child_taxon.name, child_taxon.id]
      if child_taxon.children.present?
        render_taxon_select(child_taxon, [])
      end
    end
    return subsubcategory
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

    if !self.dirty_at or self.dirty_at < 10.seconds.ago
      self.update_attribute("dirty_at", Time.now)
      #self.delay(run_at: 3.seconds.from_now).generate_image
      self.generate_image
    end

    # the board is marked as dirty whenever it is added to the delayed job queue.  That way we don't have to make countless updates but instead can just queue them all up
    # so skip this if it is already dirty...that means it has already been added to the queue
    #   unless self.is_dirty?
    #     self.update_attribute("is_dirty",1)
    #     self.delay(run_at: 3.seconds.from_now).generate_image
    #     #self.generate_image
    #   end
  end

  def self.generate_brands(searcher = nil)
    suppliers_tab = []
    if searcher.present? and searcher.solr_search.present? and searcher.solr_search.facet(:brands).present? and searcher.solr_search.facet(:brands).rows.present?
      searcher.solr_search.facet(:brands).rows.each do |supp|
        supplier = Spree::Supplier.where(name: supp.value).first
        if supplier.present?
          suppliers_tab << [supplier.name, supplier.id]
        end
      end
    end

    return suppliers_tab
  end

  def generate_image
    white_canvas = Magick::Image.new(630, 360) { self.background_color = "white" }
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
      if bp.present? and bp.product.present?

        product_image = bp.product.image_for_board(bp)
      else
        product_image =""
      end
      if product_image.present?

        # set the rotation
        product_image.rotate!(bp.rotation_offset)

        # if turned sideways, then swap the width and height when scaling
        if [90, 270].include?(bp.rotation_offset)
          product_image.scale!(bp.height, bp.width)
          top_left_x = bp.center_point_x - bp.height/2
          top_left_y = bp.center_point_y - bp.width/2

          # original width and height work if it is just rotated 180
        else
          product_image.scale!(bp.width, bp.height)
          top_left_x = bp.center_point_x - bp.width/2
          top_left_y = bp.center_point_y - bp.height/2
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
      #self.is_dirty = 0
      self.dirty_at = nil
      self.save
    end
  end

  def cache_style_and_room_type
    self.room_type = self.room.name.parameterize if self.room
    self.room_style = self.style.name.parameterize if self.style
  end

  def destroy
    self.board_products.destroy_all
    self.update_attribute('deleted_at', Time.zone.now)
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
        :subject => "Your room has been approved!",
        :from_name => "Scout & Nimble",
        :text => "#{message_content} \n\n The Scout & Nimble Team",
        :to => [
            {
                :email => self.designer.email,
                :name => self.designer.full_name
            }
        ],
        :from_email => "designer@scoutandnimble.com",
        :track_opens => true,
        :track_clicks => true,
        :url_strip_qs => false,
        :signing_domain => "scoutandnimble.com"
    }

    sending = m.messages.send_template('simple-template', [{:name => 'main', :content => html_content}, {:name => 'extra-message', :content => message_content}], message, true)

    logger.info sending
  end


  def create_or_update_board_product(params)

    if params[:products_board].present?

      board_products = JSON.parse(params[:products_board])

      board_products.each do |_, product_hash|
        if product_hash['action_board'] == 'update'
          board_product = self.board_products.where(id: product_hash['product_id']).first
          if board_product.present?
            attr = product_hash.except!('action_board', 'board_id', 'product_id')
            board_product.update(attr)
          end
        elsif product_hash['action_board'] == 'create'
          product = Spree::Product.where(id: product_hash['product_id']).first
          if product.present?
            attr = product_hash.except!('action_board', 'product_id')
            board_product = product.board_products.new(attr)
            board_product.save
          end
        end
      end
    end
  end

  def send_revision_request_email(message_content="")

    html_content = "Hi #{self.designer.full_name}, <br /> Your room, \"#{self.name}\" has been reviewed and needs revision before publishing.  Please visit the <a href=\"#{self.to_url}/design\">design page</a> to make any revisions. "

    m = Mandrill::API.new(MANDRILL_KEY)
    message = {
        :subject => "Your room status has changed: needs revision",
        :from_name => "Scout & Nimble",
        :text => "#{message_content} \n\n The Scout & Nimble Team",
        :to => [
            {
                :email => self.designer.email,
                :name => self.designer.full_name
            }
        ],
        :from_email => "designer@scoutandnimble.com",
        :track_opens => true,
        :track_clicks => true,
        :url_strip_qs => false,
        :signing_domain => "scoutandnimble.com"
    }

    sending = m.messages.send_template('simple-template', [{:name => 'main', :content => html_content}, {:name => 'extra-message', :content => message_content}], message, true)

    logger.info sending
  end


end
