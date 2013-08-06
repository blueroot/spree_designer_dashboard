Spree::Product.class_eval do
  has_many :board_products
  has_many :boards, :through => :board_products
  
end