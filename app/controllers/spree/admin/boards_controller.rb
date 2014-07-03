class Spree::Admin::BoardsController < Spree::Admin::ResourceController

  def index
    #@boards = Spree::Board.includes({:board_products => {:product => [{:master => :stock_items}, :supplier]}}, :board_image, :designer).page(params[:page]).per(params[:per_page] || 10)
    @boards = Spree::Board.includes({:board_products => {:product => [{:master => :stock_items}, :supplier]}}, :board_image, :designer)
    
    #@boards =  Spree::Board.joins(:board_products).select("spree_boards.*, count(spree_board_products.id) as product_count").group("spree_boards.id").page(params[:page]).per(params[:per_page] || 10)

    board_products = @boards.each.map(&:board_products).flatten(1)
    
    products       = board_products.map(&:product).compact

    @suppliers     = products.map(&:supplier).compact.uniq

    designers       = @boards.collect(&:designer).collect { |d| "#{d.first_name} #{d.last_name}"}.uniq

    @designer_names = ["All designers"] + designers
  end

  def update
    @board = Spree::Board.find_by id: params[:id]

    if params[:state] == "deleted"
      @board.delete_permanently
    elsif params[:state] == "request_revision"
      @board.request_revision
    elsif params[:state] == "publish"
      @board.publish
    end

    render json: @board
  end

  def new
    @board = Spree::Board.new(:name => "Untitled Room")
    @board.designer = spree_current_user
    @board.save!
  end

end
