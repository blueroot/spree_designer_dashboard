Spree::Product.class_eval do
  has_many :board_products
  has_many :boards, :through => :board_products
  has_many :bookmarks
  
  add_search_scope :in_all_taxons do |*taxons|
    taxons = get_taxons(taxons)
    id = arel_table[:id]
    joins(:taxons).where(spree_taxons: { id: taxons }).group(id).having(id.count.eq(taxons.size))
    #taxons.first ? prepare_taxon_conditions(taxons) : scoped
  end
  
  add_search_scope :available_through_boards do
    includes(:boards).where('spree_boards.id' => Spree::Board.active.collect{|board| board.id})
  end
  
  add_search_scope :by_supplier do |supplier_id|
    where(supplier_id: supplier_id)
  end
  
  def other_board_products
    self.boards.first().products
  end
  
  def self.featured
    #where(:featured => 1)
    where("spree_boards.featured_starts_at <= ? and spree_boards.featured_expires_at >= ?", Date.today, Date.today).includes(:boards, :board_products).references(:boards, :board_products)
  end
  
  def self.active
    true
    #includes(:boards).where('spree_boards.id' => Spree::Board.active.collect{|board| board.id})
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
  
  def image_for_board
    self.images.first ? Magick::ImageList.new(self.images.first.attachment.url(:product)) : Magick::ImageList.new(self.variants.first.images.first.attachment.url(:product))
  end
  
end