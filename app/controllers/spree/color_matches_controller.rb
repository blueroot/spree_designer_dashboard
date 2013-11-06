
class Spree::ColorMatchesController < Spree::StoreController
  require 'RMagick'
  include Magick 
  
  def index
    if params[:board_id] and @board = Spree::Board.find(params[:board_id])
      
      @color_matches = @board.color_matches
      
      
      respond_to do |format|
        format.js   {render :layout => false}
      end
    end
  end
  
  
  
  def create
    @board = Spree::Board.find(params[:board_id])
    unless @board.color_matches.find_by_color_id_and_board_id(params[:color_id], params[:board_id])
      @color_match = @board.color_matches.new(:color_id => params[:color_id], :board_id => params[:board_id])
    end
    
    if @color_match.save
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
