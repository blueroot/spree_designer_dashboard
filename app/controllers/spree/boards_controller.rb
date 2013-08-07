class Spree::BoardsController < Spree::StoreController
 
  
  def index
    @boards = Spree::Board.all()
  end
  
  def my_boards
    @boards = spree_current_user.boards
  end
  
  def show
    @board = Spree::Board.find(params[:id])
  end
  
  def edit
    @board = Spree::Board.find(params[:id])
  end
  
  def new
    @board = Spree::Board.new
  end
  
  def product_search
    params.merge(:per_page => "500")
    unless params[:taxon_id].blank?
      @taxon = Spree::Taxon.find(params[:taxon_id]) 
      @searcher = build_searcher(params.merge(:taxon => @taxon.id))
    else
      @searcher = build_searcher(params)
    end
    @products = @searcher.retrieve_products
    #@products = Spree::Product.all()
    respond_to do |format|
      format.js   {render :layout => false}
      #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
      #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
    end
  end
  
  def create
    @board = Spree::Board.new(params[:board])
    @board.designer = spree_current_user
    if @board.save
      redirect_to build_board_path(@board)
    else
    end
  end
  
  def update
    @board = Spree::Board.find(params[:id])
    if @board.update_attributes(params[:board])
      redirect_to "/my_boards"
    else
    end
  end
  
  def build
    @board = Spree::Board.find(params[:id])
    @products = Spree::Product.all()
    @department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children
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
