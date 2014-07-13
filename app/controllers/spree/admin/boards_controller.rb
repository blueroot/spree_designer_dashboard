class Spree::Admin::BoardsController < Spree::Admin::ResourceController

  def index
    #@boards = Spree::Board.includes({:board_products => {:product => [{:master => :stock_items}, :supplier]}}, :board_image, :designer).page(params[:page]).per(params[:per_page] || 10)
    @boards = Spree::Board.includes({:board_products => {:product => [{:master => [:stock_items, :images, :prices]}, :supplier]}}, :board_image, :designer).page(params[:page] || 1).per(params[:per_page] || 5)
    
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
      # send deletion email with params[:email] if params[:email][:should_send]
    elsif params[:state] == "request_revision"
      @board.request_revision
      # send revision email with params[:email] if params[:email][:should_send]
    elsif params[:state] == "published"
      # send publication email with params[:email] if params[:email][:should_send]
      @board.publish
    end
    
    respond_to do |format|
      if @board.update_attributes(params[:board])
        format.html {redirect_to edit_admin_board_path(@board, :notice => 'Your board was updated.')}
        format.json {render json: @board}
      else
        #format.html { render :action => ""}
      end
    end 
  end

  def new
    @board = Spree::Board.new(:name => "Untitled Room")
    @board.designer = spree_current_user
    @board.save!
  end

end
