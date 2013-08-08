
class Spree::BoardProductsController < Spree::StoreController
  require 'RMagick'
  include Magick 
  
  def index
    if params[:board_id] and @board = Spree::Board.find(params[:board_id])
      
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
      
      white_canvas = Image.new(700,400){ self.background_color = "white" }
      @board_product.board.board_products.reload
      @board_product.board.board_products.each do |bp|
      	product_image = ImageList.new(bp.product.images.first.attachment.url(:product))
      	product_image.scale!(bp.width, bp.height)
      	white_canvas.composite!(product_image, NorthWestGravity, bp.top_left_x, bp.top_left_y, Magick::OverCompositeOp)
      end
      white_canvas.format = 'jpeg'
      #white_canvas.write("#{Rails.root}/tmp/boards/#{@board_product.board.id}.jpg")
      
      #picture = imageList.flatten_images
      file = Tempfile.new("board_#{@board_product.board.id}.jpg")
      white_canvas.write(file.path)
      @board_product.board.build_board_image if @board_product.board.board_image.blank?
      @board_product.board.board_image.attachment = file      
      @board_product.board.save
      respond_to do |format|
      
        format.js   { render :action => "show" }
        #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
        #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
      end
    else
    end
  end
  

  
  def destroy
    if @board_product = Spree::BoardProduct.find_by_product_id_and_board_id(params[:id], params[:board_id])
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
