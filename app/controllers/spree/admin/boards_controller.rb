class Spree::Admin::BoardsController < Spree::Admin::ResourceController


 
  def index
    @boards = Spree::Board.all.select { |board| board.board_products.count > 0 }

    @boards = @boards.select do |board| 
      board_product_count = 0
      board.board_products.each do |bp|
        board_product_count += 1 unless bp.product.nil?
      end
      puts "#{board.name} has #{board_product_count} products"
      board_product_count > 0
    end
    @board_products = Spree::BoardProduct.all.select {|bp| bp.approved_at == nil && bp.removed_at == nil  }
    @products       = @board_products.map(&:product).compact
    @suppliers      = @products.map(&:supplier).compact.uniq
    @designers      = Spree::DesignerRegistration.all
    #@supplier_names = ["All designers"] + @suppliers.map(&:name).compact.uniq
    @designer_names = ["All designers"] + @designers.map { |d| "#{d.first_name}" + " #{d.last_name}" } - [" "] 
  end


  def new
    @board = Spree::Board.new(:name => "Untitled Room")
    @board.designer = spree_current_user
    @board.save!
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
