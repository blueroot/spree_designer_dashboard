class Spree::ColorMatchesController < Spree::StoreController
  before_filter :require_authentication
  require 'RMagick'
  include Magick 
  
  def index
    if params[:room_id] and @board = Spree::Board.find(params[:room_id])
      
      @color_matches = @board.color_matches
      
      
      respond_to do |format|
        format.js   {render :layout => false}
      end
    end
  end
  
  
  
  def create
    @board = Spree::Board.find(params[:room_id])

    if params[:id] and @color_match = @board.color_matches.find(params[:id])
      
    else  
      if params[:colorid].present?
       @color_id = Spree::Color.find_by_swatch_val(params[:colorid]).id
	      unless @color_match = @board.color_matches.find_by_color_id(@color_id)
	        @color_match = @board.color_matches.new(:color_id => @color_id, :board_id => params[:room_id])
	      end
     else
	      unless @color_match = @board.color_matches.find_by_color_id(params[:color_id])
	        @color_match = @board.color_matches.new(:color_id => params[:color_id], :board_id => params[:room_id])
	      end
	 end
	 
    end
    
    if params[:colorid].present?
       @color_collection = Spree::ColorCollection.find(params[:color_collection_id])
       @colors = @color_collection.colors
       @color=@colors.find_by_swatch_val(params[:colorid])
       if @color.present?
         @color_id = @color.id
         @colorpresent = '1'
       else
        @colorpresent = '0'
          redirect_to :back, :notice => 'Wrong Color Code.'
       end
	       if @colorpresent == '1'
	         @color_match.update_attributes(:color_id => @color_id, :board_id => params[:room_id])
	         
	       end
	end
    if @color_match.save && @colorpresent == '1'
      @color_collections = Spree::ColorCollection.all()
       #sleep(100.0)
      respond_to do |format|
      
        format.js   { render :action => "show" }
        
      end
    else
    end
  end
  
 def getcolors
     if params[:colorid].present?
       @color_collection = Spree::ColorCollection.find(params[:color_collection_id])
       @colors = @color_collection.colors
       @color=@colors.find_by_swatch_val(params[:colorid])
       puts @color.inspect
         render json: @color.hex_val.to_json 
  
 end
        
       
 end
  
  def destroy
    @board = Spree::Board.find(params[:room_id])
    @color_collections = Spree::ColorCollection.all()
    if params[:id] and @color_match = @board.color_matches.find(params[:id])
      @color_match.destroy
      
    end
    respond_to do |format|
      format.js   { render :action => "show" }
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
