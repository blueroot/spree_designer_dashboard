
class Spree::BoardProductsController < Spree::StoreController
  require 'RMagick'
  include Magick 
  
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
    
    if @board_product.update_attributes(params[:board_product])
      @board_product.board.queue_image_generation
      respond_to do |format|
        format.json   {render :layout => false, :action => "show"}
      end
    else
    end
  end
  
  def create
    if @board_product = Spree::BoardProduct.find_by_product_id_and_board_id(params[:board_product][:product_id], params[:board_product][:board_id])
      @board_product.attributes = params[:board_product]
    else
      @board_product = Spree::BoardProduct.new(params[:board_product])
    end
    
    if @board_product.save
      @board_product.board.queue_image_generation

      respond_to do |format|
        format.js   { render :action => "show" }
        format.json   {render :layout => false}
        #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
        #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
      end
    else
    end
  end
  
  def destroy
    if @board_product = Spree::BoardProduct.find_by_product_id_and_board_id(params[:id], params[:room_id])
      @board_product.destroy
    end
    respond_to do |format|
      format.js   { render :text => "Deleted" }
      #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
      #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
    end
  end
    
  
end
