class Spree::BoardsController < Spree::StoreController
 
  
  def index
    @boards = Spree::Board.all()
  end
  
  def my_boards
    @boards = spree_current_user.boards
  end
  
  def new
    @board = Spree::Board.new
  end
  
  def create
    @board = Spree::Board.new(params[:board])
    if @board.save
      redirect_to build_board_path(@board)
    else
    end
  end
  
  def build
    @board = Spree::Board.find(params[:id])
    @products = Spree::Product.all()
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
