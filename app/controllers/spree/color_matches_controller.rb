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

    if params[:id] and @color_match = @board.color_matches.find(params[:id])
      
    else  
      unless @color_match = @board.color_matches.find_by_color_id(params[:color_id])
        @color_match = @board.color_matches.new(:color_id => params[:color_id], :board_id => params[:board_id])
      end
    end
    
    if @color_match.save
      respond_to do |format|
        format.js   { render :action => "show" }
      end
    else
    end
  end
  

  
  def destroy
    @board = Spree::Board.find(params[:board_id])

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
