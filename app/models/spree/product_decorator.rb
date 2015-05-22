Spree::Product.class_eval do
  has_many :board_products
  has_many :boards, :through => :board_products
  has_many :bookmarks

  before_save :update_product_publish_status

  def update_product_publish_status
    if self.boards.any?{|board| board.status == "published"} or self.available_sans_board == true
      self.is_published = 1
    else
      self.is_published = 0
    end
  end

  add_search_scope :in_all_taxons do |*taxons|
    taxons = get_taxons(taxons)
    id = arel_table[:id]
    joins(:taxons).where(spree_taxons: { id: taxons }).group(id).having(id.count.eq(taxons.size))
    #taxons.first ? prepare_taxon_conditions(taxons) : scoped
  end

  add_search_scope :available_through_boards do
    includes(:boards).where('spree_boards.id' => Spree::Board.active.collect{|board| board.id}).includes(:master => [:images])
  end

  #same as available_through_boards, but also adds those that have been handpicked
  add_search_scope :available_sans_boards do
    where(available_sans_board: 1).includes(:master => [:images])
  end

  add_search_scope :available_through_published_boards do
    includes(:boards).where('spree_boards.id' => Spree::Board.published.collect{|board| board.id})
  end

  add_search_scope :by_supplier do |supplier_id|
    where(supplier_id: supplier_id)
  end

  add_search_scope :by_board do |board_id|
    includes(:board_products).where(:spree_board_products => { :board_id => board_id })
  end

  add_search_scope :not_on_a_board do
    includes(:board_products).where(:spree_board_products => { :id => nil })
  end

  add_search_scope :available_for_public do
    where('is_published = 1').includes(:master => [:images])
  end

  # exactly the same as the "available_for_public" search scope, but is a basic product scope and doesn't include the master variant by defaults, so possibly faster
  def self.published
    where('is_published = 1')
  end

  def self.discontinued
    where('not isnull(discontinued_at)')
  end

  def self.marked_for_removal
    includes(:board_products).where("spree_board_products.state in ('marked_for_removal', 'marked_for_deletion')")
  end

  def self.marked_for_approval
    includes(:board_products).where("spree_board_products.state in ('marked_for_approval')")
  end

  def self.pending_approval
    includes(:board_products).where("spree_board_products.state in ('pending_approval')")
    #includes(:board_products, :boards).where("spree_boards.state = 'submitted_for_publication' and spree_products.is_published = 0 and isnull(spree_products.deleted_at) and isnull(spree_products.discontinued_at) and isnull(spree_board_products.approved_at) and isnull(spree_board_products.removed_at)")
  end

  def self.bookmarked
    includes(:bookmarks)
  end


  def promoted_board
    if self.boards and self.boards.first
      self.boards.first
    else
      false
    end
  end

  #scope :not_on_a_board, includes(:board_products).where(:spree_board_products => { :id => nil })

  def other_board_products
    self.boards.first().products
  end

  def self.featured
    #where(:featured => 1)
    where("spree_boards.featured_starts_at <= ? and spree_boards.featured_expires_at >= ?", Date.today, Date.today).includes(:boards, :board_products).references(:boards, :board_products)
  end

  def self.on_a_board
    includes(:boards).where('spree_boards.id' => Spree::Board.all().collect{|board| board.id})
  end

  # making a product available on the site depends on a number of things
  # - available_at is <= Now
  # - it's on a board OR it's available manually (available_sans_board)
  # So it is a UNION operation that, one part of which relies on a join.
  # Really slow when done in ActiveRecord.
  # Could be optimized in custom SQL, but probably just faster to just cache in a single "is_published" field on the product
  def published?
    self.is_published
  end

  # discontinued is for when items are published and should stay on the site as "sold out" instead of being deleted
  def discontinued?
    !!discontinued_at
  end

  def is_on_board?
    !self.board_products.blank?
  end

  def not_on_a_board?
    self.board_products.blank?
  end

  def is_bookmarked_by?(user)
    self.bookmarks.find_by_user_id(user.id) ? true : false
  end

  def image_for_board(board_product)

    #image = Magick::ImageList.new
    #urlimage = self.images.first ? open(self.images.first.attachment.url(:product)) : open(self.variants.first.images.first.attachment.url(:product))
    #image.from_blob(urlimage.read)

    begin

      image = Spree::Image.where(id: board_product.image_id).first
      if image.present?
        image_url = image.attachment.url(:product)
      else
        image_url = self.images.first.attachment.url(:product)
      end
      self.images.first ? Magick::ImageList.new(image_url) : Magick::ImageList.new(image.present? ? image.attachment.url(:product)  : self.variants.first.images.first.attachment.url(:product))
    rescue Exception => e
      puts "================"
      puts e.inspect
      puts "================"
    end
  end

  def self.like_any(fields, values)
    where fields.map { |field|
      values.map { |value|
        arel_table[field].matches("%#{value}%")
      }.inject(:and)
    }.inject(:or)
  end

end