class Spree::Admin::BoardProductsController < Spree::Admin::ResourceController


 
  def index
    @boards         = Spree::Board.all
    @board_products = Spree::BoardProduct.all.select {|bp| bp.approved_at == nil && bp.removed_at == nil  }
    @products       = @board_products.map(&:product).compact
    @suppliers      = @products.map(&:supplier).compact.uniq
    @supplier_names = ["All suppliers"] + @suppliers.map(&:name).compact.uniq
  end
  
  
  # redirect to the edit action after create
  #  create.response do |wants|
  #    wants.html { redirect_to edit_admin_fancy_thing_url( @fancy_thing ) }
  #  end
  #  
  #  # redirect to the edit action after update
  #  update.response do |wants|
  #    wants.html { redirect_to edit_admin_fancy_thing_url( @fancy_thing ) }
  #  end
 
end
