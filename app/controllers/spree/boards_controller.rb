class Spree::BoardsController < Spree::StoreController
  helper 'spree/taxons'
  helper 'spree/products'
  before_filter :require_authentication
  before_filter :prep_search_collections, :only => [:index, :search, :edit, :new, :design]
  impressionist :actions=>[:show]

  def index
    @boards = Spree::Board.featured()
    @products = Spree::Product.featured()
  end
  
  def home
    @boards = Spree::Board.featured().limit(3)
    @board = Spree::Board.featured().order("featured_starts_at desc").first
    lroom, droom, broom = Spree::Taxon.find_by_name('Living Room'), Spree::Taxon.find_by_name('Dining Room'), Spree::Taxon.find_by_name('Bedroom')
    @living_room_boards = Spree::Board.featured().by_room(Spree::Taxon.find_by_name('Living Room').id)
    @dining_room_boards = Spree::Board.featured().by_room(droom.id)
    @bedroom_boards = Spree::Board.featured().by_room(broom.id)
    @products = Spree::Product.featured()
    @product = Spree::Product.where("homepage_featured_starts_at <= ? and homepage_featured_ends_at >= ?", Date.today, Date.today).order("homepage_featured_starts_at desc").first

    @selected_section = "home"
    @designers = Spree::User.is_active_designer().limit(4)
    @designer =  Spree::User.where("designer_featured_starts_at <= ? and designer_featured_ends_at >= ?", Date.today, Date.today).order("designer_featured_starts_at desc").first
    puts @designer.inspect
    render :layout => "/spree/layouts/spree_home"
  end
  
  def search
    
    @boards_scope = Spree::Board.active
    if params[:color_family] == 0
        params[:color_family] = nil
      end
    unless params[:color_family].blank?
     
      #@related_colors = Spree::Color.by_color_family(params[:color_family])
      @boards_scope = @boards_scope.by_color_family(params[:color_family])
    end
    if params[:room_id] == '0'
        params[:room_id] = nil
      end
    unless params[:room_id].blank?
      
      @boards_scope = @boards_scope.by_room(params[:room_id])
    end
      if params[:style_id] == 0
        params[:style_id] = nil
      end
    unless params[:style_id].blank?
     
      @boards_scope = @boards_scope.by_style(params[:style_id])
    end
      if params[:designer_id] == 0
        params[:designer_id] = nil
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
    impressionist(@board)
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
    #if params[:supplier_id]
    #  params.merge(:supplier_id => params[:supplier_id])
    #end
    taxons = []
    #unless params[:wholesaler_taxon_id].blank?
    #  taxon = Spree::Taxon.find(params[:wholesaler_taxon_id])
    #  taxons << taxon.id
    #end
    
    if !params[:department_taxon_id].blank? and !params[:department_taxon_id] == "Department"
      taxon = Spree::Taxon.find(params[:department_taxon_id])
      taxons << taxon.id
    end
    
    unless taxons.empty? 
      @searcher = build_searcher(params.merge(:taxon => taxons))
    else
      @searcher = build_searcher(params)
    end
    if params[:supplier_id] and params[:supplier_id].to_i > 0
      @all_products = @searcher.retrieve_products.by_supplier(params[:supplier_id]).not_on_a_board
    else
      @all_products = @searcher.retrieve_products.not_on_a_board
    end
    @products = @all_products
    
    #@products = @all_products.select { |product| product.not_on_a_board? }
    #if params[:supplier_id]
    #  @products = @all_products.by_supplier(params[:supplier_id])
    #else
    #  @products = @all_products.by_supplier(supplier_id)
    #end
    
    @board = Spree::Board.find(params[:board_id])
    
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
  
  def gettaxons

    @searcher = build_searcher(params.merge(:supplier_id => params[:supplier_id], :per_page => 5000))
    @supplierid = params[:supplier_id]
    if params[:supplier_id].present?
      @all_products = @searcher.retrieve_products.by_supplier(params[:supplier_id])
    else
      @all_products = @searcher.retrieve_products
    end
    
    department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children
    product_taxon_ids = @all_products.collect{|p| p.taxons.collect{|t| t.id} }.flatten.uniq
    @ary = department_taxons.where(:id => product_taxon_ids).map{|taxon| [taxon.name, taxon.id]}
    
    #@ary = Array.new(Array.new) 
    #
    #
    #
    #@all_products.each do |prod|
    #  @prod = Spree::Product.find_by_id(prod.id)
    #  @prod.taxons.each do |tax|
    #    @ary.push([tax.name,tax.id])
    #  end
    #end
    render :json => @ary
  end
  
  def design
    
    @board = Spree::Board.find(params[:id])
    @board.messages.new(:sender_id => spree_current_user.id, :recipient_id => 0, :subject => "Publication Submission")
    @products = Spree::Product.all()
    @bookmarked_products = spree_current_user.bookmarks.collect{|bookmark| bookmark.product}
    @department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children
    #@department_taxons= Spree::Supplier.find_by(id: 16).taxons 
      @searcher = build_searcher(params)
     
      @all_products = @searcher.retrieve_products.by_supplier('')
      @ary = Array.new(Array.new) 
     
      @all_products.each do |prod|
         @prod = Spree::Product.find_by_id(prod.id)
   
          @prod.taxons.each do |tax|
             @ary.push([tax.name,tax.id])
          end
      end
   
    @suppliers = Spree::Supplier.where(:public => 1).order(:name)
    #@wholesaler_taxons = Spree::Taxonomy.where(:name => 'Wholesaler').first().root.children

    @color_collections = Spree::ColorCollection.all()
  end
  
  def destroy
    @board = spree_current_user.boards.find(params[:id])
    if @board and @board.destroy
      flash[:notice] = "The room has been deleted."
    else
      flash[:warning] = "We could not delete this room."
    end
    redirect_to designer_dashboard_path
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



