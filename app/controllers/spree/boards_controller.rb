class Spree::BoardsController < Spree::StoreController
  helper 'spree/taxons'
  helper 'spree/products'
  
  before_filter :prep_search_collections, :only => [:index, :search, :edit, :new, :design]
  impressionist :actions=>[:show]

  def index
    @boards = Spree::Board.featured()
    @products = Spree::Product.featured()
  end
  
  def home
    @boards = Spree::Board.featured().limit(3)
    lroom, droom = Spree::Taxon.find_by_name('Living Room'), Spree::Taxon.find_by_name('Dining Room')
    @living_room_boards = Spree::Board.featured().by_room(Spree::Taxon.find_by_name('Living Room').id)
    @dining_room_boards = Spree::Board.featured().by_room(droom.id)
    
    @products = Spree::Product.featured()
    render :layout => "/spree/layouts/spree_home"
  end
  
  def search
    
    @boards_scope = Spree::Board.active
    
    unless params[:color_family].blank?
      #@related_colors = Spree::Color.by_color_family(params[:color_family])
      @boards_scope = @boards_scope.by_color_family(params[:color_family])
    end
    
    unless params[:room_id].blank?
      @boards_scope = @boards_scope.by_room(params[:room_id])
    end
    
    unless params[:style_id].blank?
      @boards_scope = @boards_scope.by_style(params[:style_id])
    end
    
    unless params[:designer_id].blank?
      @boards_scope = @boards_scope.by_designer(params[:designer_id])
    end
    
    unless params[:price_high].blank?
      @boards_scope = @boards_scope.by_upper_bound_price(params[:price_high])
    end
    
    unless params[:price_low].blank?
      @boards_scope = @boards_scope.by_lower_bound_price(params[:price_low])
    end
    
    
    
    @selected_color_family = params[:color_family] || ""
    @selected_room = params[:room_id] || ""
    @selected_style = params[:style_id] || ""
    @selected_designer = params[:designer_id] || ""
    @selected_price_low = params[:price_low] || ""
    @selected_price_high = params[:price_high] || ""
    
    
    @boards = @boards_scope
  end
  
  def my_rooms
    @boards = spree_current_user.boards
  end
  
  def show
    @board = Spree::Board.find(params[:id])
  end
  
  def preview
    @board = Spree::Board.find(params[:id])
    render :action => "show"
  end
  
  def edit
    @board = Spree::Board.find(params[:id])
    @colors = Spree::Color.order(:position).where("position > 144 and position < 1000")
    num_colors = @board.colors.size + 1
    num_colors.upto(5) do |n|
      @board.colors.build
    end
  end
  
  def new
    @board = Spree::Board.new(:name => "Untitled Room")
    @board.designer = spree_current_user
    @board.save!
    redirect_to design_board_path(@board)
    
    #@colors = Spree::Color.order(:position).where("position > 144 and position < 1000")

    #1.upto(5) do |n|
    #  @board.colors.build
    #end
  end
  
  def product_search
    params.merge(:per_page => 100)
    taxons = []
    unless params[:wholesaler_taxon_id].blank?
      taxon = Spree::Taxon.find(params[:wholesaler_taxon_id])
      taxons << taxon.id
    end
    
    unless params[:department_taxon_id].blank?
      taxon = Spree::Taxon.find(params[:department_taxon_id])
      taxons << taxon.id
    end
    
    unless taxons.empty? 
      @searcher = build_searcher(params.merge(:taxon => taxons))
    else
      @searcher = build_searcher(params)
    end
    
    @all_products = @searcher.retrieve_products
    @products = @all_products.select { |product| !product.is_on_board? }
    
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
      redirect_to designer_dashboard_path(@board, :notice => 'Your board was updated.')
    else
    end
  end
  
  def build
    @board = Spree::Board.find(params[:id])
    @products = Spree::Product.all()
    @department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children
    @wholesaler_taxons = Spree::Taxonomy.where(:name => 'Wholesaler').first().root.children
  end
  
  def design
    @board = Spree::Board.find(params[:id])
    @board.messages.new(:sender_id => spree_current_user.id, :recipient_id => 0, :subject => "Publication Submission")
    @products = Spree::Product.all()
    @department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children
    @wholesaler_taxons = Spree::Taxonomy.where(:name => 'Wholesaler').first().root.children
  end
  
  private
    def prep_search_collections
      @room_taxons = Spree::Taxonomy.where(:name => 'Rooms').first().root.children.select{|child| Spree::Board.available_room_taxons.include?(child.name) }
      @style_taxons = Spree::Taxonomy.where(:name => 'Styles').first().root.children
      @colors = Spree::Color.order(:position)
      @designers = Spree::User.is_active_designer
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



