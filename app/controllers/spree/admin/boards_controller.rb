class Spree::Admin::BoardsController < Spree::Admin::ResourceController

  def index
    @boards         = Spree::Board.includes(:board_products).page(params[:page]).per(params[:per_page] || 10)

    board_products = @boards.each.map(&:board_products).flatten(1)
    
    products       = board_products.map(&:product).compact

    @suppliers     = products.map(&:supplier).compact.uniq

    designers       = @boards.collect(&:designer).collect { |d| "#{d.first_name} #{d.last_name}"}.uniq

    @designer_names = ["All designers"] + designers
  end

  def new
    @board = Spree::Board.new(:name => "Untitled Room")
    @board.designer = spree_current_user
    @board.save!
  end

end
