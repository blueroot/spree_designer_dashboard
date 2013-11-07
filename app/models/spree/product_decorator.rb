Spree::Product.class_eval do
  has_many :board_products
  has_many :boards, :through => :board_products
  
  add_search_scope :in_all_taxons do |*taxons|
    taxons = get_taxons(taxons)
    id = arel_table[:id]
    joins(:taxons).where(spree_taxons: { id: taxons }).group(id).having(id.count.eq(taxons.size))
    #taxons.first ? prepare_taxon_conditions(taxons) : scoped
  end
  
  add_search_scope :available_through_boards do
    includes(:boards).where('spree_boards.id' => Spree::Board.active.collect{|board| board.id})
  end
  
  def other_board_products
    self.boards.first().products
  end
end