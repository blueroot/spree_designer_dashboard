class Spree::BoardProductsController < Spree::StoreController
  #require 'RMagick'
  #include Magick 
  before_filter :require_authentication
  def index
    if params[:room_id] and @board = Spree::Board.find(params[:room_id])      
      @board_products = @board.board_products(:include => [:master_images, :product])
      respond_to do |format|
        format.js   {render :layout => false}
        format.json   {render :layout => false}
      end
    end
  end
  
  def new
    @board_product = Spree::BoardProduct.new
  end
  
  
  def update
    @board_product = Spree::BoardProduct.find(params[:id])
    @board = @board_product.board
    if @board_product.update_attributes(board_product_params)
      @board_product.board.queue_image_generation
      
      respond_to do |format|
        format.json   {render :layout => false, :action => "show"}
      end
    else
    end
  end
  
  def create
    
    if params[:board_product][:id] and @board_product = Spree::BoardProduct.find(params[:board_product][:id])
      
      @board_product.attributes = params[:board_product]
    #elsif @board_product = Spree::BoardProduct.find_by_product_id_and_board_id(params[:board_product][:product_id], params[:board_product][:board_id])
      #@board_product.attributes = params[:board_product]
    else
      @board_product = Spree::BoardProduct.new(board_product_params)
    end

    if @board_product.save
      @board = @board_product.board
      if @board_product.product.present?
        @board_product.product.update(in_rooms: true)
      end
      @board_product.board.queue_image_generation
      respond_to do |format|
        format.js   { render :action => "show" }
        format.json   {render :action => "show", :layout => false}
      end
    end
  end
  
  def destroy
    if @board_product = Spree::BoardProduct.find(params[:id])
      @board_product.destroy
      
    end
    respond_to do |format|
      format.js   { render :text => "Deleted" }
      #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
      #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
    end
  end
  
  private
    def board_product_params
      params.require(:board_product).permit(:board_id, :product_id, :top_left_x, :top_left_y, :center_point_x, :center_point_y, :z_index, :status, :width, :height, :rotation_offset)
    end
    
  
end
