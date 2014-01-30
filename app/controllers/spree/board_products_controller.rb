
class Spree::BoardProductsController < Spree::StoreController
  require 'RMagick'
  include Magick 
  
  def index
    if params[:room_id] and @board = Spree::Board.find(params[:room_id])
      
      @board_products = @board.board_products(:include => :master_images)
      
      
      ## Build a JSON object containing our HTML
      #json = {"html" => render_to_string(partial: 'products.html.erb', locals: { :board_products => @board_products })}.to_json
      ## Get the name of the JSONP callback created by jQuery
      #callback = ""
      ## Wrap the JSON object with a call to the JSONP callback
      #jsonp = callback + "(" + json + ")"
      ## Send result to the browser
      #render :text => jsonp,  :content_type => "text/javascript"
      
      
      respond_to do |format|
        format.js   {render :layout => false}
        #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
        #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
      end
    end
  end
  
  def new
    @board_product = Spree::BoardProduct.new
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
    
  
  # redirect to the edit action after create
  #create.response do |wants|
  #  show.html { redirect_to edit_admin_fancy_thing_url( @fancy_thing ) }
  #end
  #
  ## redirect to the edit action after update
  #update.response do |wants|
  #  wants.html { redirect_to edit_admin_fancy_thing_url( @fancy_thing ) }
  #end
 
end
