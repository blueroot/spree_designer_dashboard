class Spree::BoardsController < Spree::StoreController
  helper 'spree/taxons'
  helper 'spree/products'
  before_filter :require_authentication, :only => [:new, :design, :preview, :dashboard, :my_profile, :store_credit, :design2]
  before_filter :prep_search_collections, :only => [:index, :search, :edit, :new, :design, :design2]
  before_filter :load_board, :only => [:preview, :design, :destroy, :update, :design2]
  before_filter :require_board_designer, :only => [:dashboard]
  before_filter :get_room_manager, :only => [:submit_for_publication]

  impressionist :actions => [:show]

  def require_board_designer
    if !(spree_current_user and spree_current_user.is_board_designer?)
      if spree_current_user.is_affiliate?
        redirect_to my_profile_path
      else
        redirect_to root_path
      end
    end
  end

  def load_board
    unless @board = spree_current_user.boards.friendly.find(params[:id])
      redirect_to root_path
    end
  end

  def index
    @boards = Spree::Board.published().order("created_at desc")
    #@products = Spree::Product.featured()
  end

  def dashboard
    @boards = spree_current_user.boards.where(removal: false)
    end

  def profile
    @user = spree_current_user
    if spree_current_user and (spree_current_user.is_beta_user? or spree_current_user.is_designer?)

      @user.user_images.new if @user.user_images.blank?
      @user.marketing_images.new if @user.marketing_images.blank?
      @user.build_logo_image if @user.logo_image.blank?
    else
      redirect_to "/"
    end
  end

  def store_credit
    @user = spree_current_user
  end


  def home
    @boards = Spree::Board.featured().limit(3)
    @board = Spree::Board.featured().order("featured_starts_at desc").first
    lroom, droom, broom = Spree::Taxon.find_by_permalink('rooms/living-room'), Spree::Taxon.find_by_permalink('rooms/dining-room'), Spree::Taxon.find_by_permalink('rooms/bedroom')
    @living_room_boards = Spree::Board.featured().by_room(lroom.id)
    @dining_room_boards = Spree::Board.featured().by_room(droom.id)
    @bedroom_room_boards = Spree::Board.featured().by_room(broom.id)
    @products = Spree::Product.featured()
    #@product = Spree::Product.where("homepage_featured_starts_at <= ? and homepage_featured_ends_at >= ?", Date.today, Date.today).order("homepage_featured_starts_at desc").first

    @selected_section = "home"
    @designers = Spree::User.published_designers().order("created_at desc")

    @slides = Spree::Slide.current.order("created_at desc") || Spree::Slide.defaults


    #@featured_designer = Spree::User.where("designer_featured_starts_at <= ? and designer_featured_ends_at >= ?", Date.today, Date.today).order("designer_featured_starts_at desc").first || Spree::User.published_designers.first
    #@featured_room = @featured_designer.boards.published().featured().last
    #@featured_products = []
    #@featured_products = @featured_room.products.limit(4) if @featured_room
    #puts @designer.inspect
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

  def set_out_of_stock_in_room
    @board = Spree::Board.where(slug: params[:slug]).first
    @board.update(show_out_of_stock: params[:value])
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def show
    @board = Spree::Board.friendly.find(params[:id])
    impressionist(@board)
  end

  def preview
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

  def reload_filters
    @board = Spree::Board.where(id: params[:board_id]).first
    @my_taxon = Spree::Taxon.where(id: params[:room_id]).first
    @searcher = build_searcher(params)
    #@taxon_filters = Spree::Product.generate_new_filters(@my_taxon)
    @searcher.retrieve_products({where: "supplier_id = #{@my_taxon.id}"})
    respond_to do |format|
      format.html { render :layout => false }
    end

  end

  def product_result
    params.merge(:per_page => 60)
   
    @board = Spree::Board.where(id: params[:board_id]).first

    if @board.present? and @board.show_out_of_stock == true
      out_of_stock = {order: "quantity_on_hand DESC, spree_variants.backorderable DESC"}
    else
      out_of_stock = {where: "quantity_on_hand > 0 "}
    end
    taxons = []
    unless taxons.empty?
      @searcher = build_searcher(params.merge(:taxon => taxons))
    else
      @searcher = build_searcher(params)
    end
    if params[:supplier_id] and params[:supplier_id].to_i > 0
      @all_products = @searcher.retrieve_products({where: "supplier_id = #{params[:supplier_id]}"}, out_of_stock,  {page: params[:page] || 1, per_page: params[:per_page] || 60})
    else
      @all_products = @searcher.retrieve_products(out_of_stock,  {page: params[:page] || 1, per_page: params[:per_page] || 60})
    end
    @products = @all_products

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def product_search
    params.merge(:per_page => 100)
    if params[:s].present?
      w = params[:s].each do |key, val|
        if val.class != [].class
          val = YAML.load(val)
          params[:s][key.to_sym] = val
        end
      end
      params[:s] = w
    end
    #if params[:supplier_id]
    #  params.merge(:supplier_id => params[:supplier_id])
    #end
    taxons = []
    #unless params[:wholesaler_taxon_id].blank?
    #  taxon = Spree::Taxon.find(params[:wholesaler_taxon_id])
    #  taxons << taxon.id
    #end

    #if params[:id] and !params[:id].empty?
    #  taxon = Spree::Taxon.find(params[:department_taxon_id])
    #  taxons << taxon.id
    #end
    @my_taxon = Spree::Taxon.where(id: params[:id]).first
    #@taxon_filters = Spree::Product.generate_new_filters(@my_taxon)


    unless taxons.empty?
      @searcher = build_searcher(params.merge(:taxon => taxons))
    else
      @searcher = build_searcher(params)
    end
    if params[:supplier_id] and params[:supplier_id].to_i > 0
      # @all_products = @searcher.retrieve_products.by_supplier(params[:supplier_id]).not_on_a_board
      #@all_products =  @searcher.retrieve_products({where: "supplier_id = #{params[:supplier_id]}"}, {includes: :board_products}, {where: "spree_board_products.product_id is NULL"})
      @all_products = @searcher.retrieve_products({where: "supplier_id = #{params[:supplier_id]}"}, {order: "quantity_on_hand DESC, spree_variants.backorderable DESC"})
    else
      # @all_products = @searcher.retrieve_products.not_on_a_board
      #@all_products = @searcher.retrieve_products( {includes: :board_products}, {where: "spree_board_products.product_id is NULL"})
      @all_products = @searcher.retrieve_products({order: "quantity_on_hand DESC, spree_variants.backorderable DESC"})
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
      format.js { render :layout => false }
      #format.html { redirect_to([:admin, @booking], :notice => 'Booking was successfully created.') }
      #format.xml  { render :xml => @booking, :status => :created, :location => @booking }
    end
  end

  def create
    @board = Spree::Board.new(board_params)
    @board.designer = spree_current_user
    if @board.save
      redirect_to build_board_path(@board)
    else
    end
  end

  def update
    @board.slug = nil
    #respond_to do |format|
    @board.create_or_update_board_product(params)
    if @board.update_attributes(board_params)
      @board.submit_for_publication! if params[:board][:status] == "submitted_for_publication"
      @board.queue_image_generation
      redirect_to designer_dashboard_path(@board, :notice => 'Your board was updated.')
    else
      puts @board.errors.collect { |e| e.to_s }
      #format.html { render :action => "design"}
    end
    #end
  end

  def submit_for_publication

    @board = Spree::Board.find_by slug: params[:id]
    @board.set_state_transition_context(params[:board][:state_message], spree_current_user)
    @board.submit_for_publication
    html_content = "There is a new room for you to review."
    html_content << "<br /><br />Message from Designer:<br /><br />#{params[:board][:state_message]}" if params[:board] and params[:board][:state_message] and !params[:board][:state_message].blank?

    @board.designer.send_message(@room_manager, "Room Submitted by #{@board.designer.full_name}", html_content, true, nil, Time.now, @board)
    redirect_to designer_dashboard_path
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
    product_taxon_ids = @all_products.collect { |p| p.taxons.collect { |t| t.id } }.flatten.uniq
    @ary = department_taxons.where(:id => product_taxon_ids).map { |taxon| [taxon.name, taxon.id] }

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
    @category = []
    @subcategory = []
    @sub_subcategory = []
    @category_id = ""
    @subcategory_id = ""
    @sub_subcategory_id = ""
    @supplier = Spree::Supplier.new
    @my_taxon = Spree::Taxon.where(name: 'Department').first
    @my_taxon.children.each do |taxon|
      @category << [taxon.name, taxon.id]
    end

    #@board.messages.new(:sender_id => spree_current_user.id, :recipient_id => 0, :subject => "Publication Submission")
    @products = Spree::Product.all()
    @bookmarked_products = spree_current_user.bookmarks.collect { |bookmark| bookmark.product }
    @department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children

    #@department_taxons= Spree::Supplier.find_by(id: 16).taxons 
    @searcher = build_searcher(params)

    @all_products = @searcher.retrieve_products.by_supplier('')
    @ary = Array.new(Array.new)

    @all_products.each do |prod|
      @prod = Spree::Product.find_by_id(prod.id)

      @prod.taxons.each do |tax|
        @ary.push([tax.name, tax.id])
      end
    end

    #@wholesaler_taxons = Spree::Taxonomy.where(:name => 'Wholesaler').first().root.children

    @color_collections = Spree::ColorCollection.all()
  end

  def search_all_categories
    @subcategory = []
    @sub_subcategory = []
    @category = []
    @suppliers = []
    @board = Spree::Board.where(id: params[:board_id]).first
    if params[:supplier_id].present?
      @supplier = Spree::Supplier.where(id: params[:supplier_id]).first
    else
      @supplier = Spree::Supplier.new
    end
    tab = []

    if params[:keywords].present?
      @searcher = build_searcher(params)
      @searcher.retrieve_products
      tab = @searcher.solr_search.facet(:brand_name).rows.map(&:value)
      if params[:type].blank? and params[:id].blank?
        params[:type] = 'categories'
        params[:id] = Spree::Taxon.where(permalink: tab.first).first.id
        @room_id = params[:id]
      end
    end

    @category_find = Spree::Taxonomy.where(:name => 'Department').first.root.children
    @category_find.map do |tax|
      if tab.present?
        if tab.include?(tax.name)
          @category << [tax.name, tax.id]
        end
      else
        @category << [tax.name, tax.id]
      end
    end


    if params[:type].to_s == "categories"
      @category_id = Spree::Taxon.where(id: params[:id]).first
      params[:s] = {} if params[:s].blank?
      params[:s][:brand_name] = @category_id.permalink
      @searcher = build_searcher(params)
      @searcher.retrieve_products
      @suppliers = Spree::Board.generate_brands(@searcher)
      @category_id.children.each do |taxon|
        if tab.present?
          if tab.include?(taxon.permalink)
            @subcategory << [taxon.name, taxon.id]
          end
        else
          @subcategory << [taxon.name, taxon.id]
        end
      end
      #@taxon_filters = Spree::Product.generate_new_filters(@category_id)
    elsif params[:type].to_s == "subcategories"
      @subcategory_id = Spree::Taxon.where(id: params[:id]).first
      params[:s] = {} if params[:s].blank?
      params[:s][:brand_name] = @subcategory_id.permalink
      @searcher = build_searcher(params)
      @searcher.retrieve_products
      @suppliers = Spree::Board.generate_brands(@searcher)
      @category_id = Spree::Taxon.where(id: @subcategory_id.parent.id).first

      @category_id.children.each do |taxon|
        if tab.present?
          if tab.include?(taxon.name)
            @subcategory << [taxon.name, taxon.id]
          end
        else
          @subcategory << [taxon.name, taxon.id]
        end
      end

      @subcategory_id.children.each do |taxon|
        if tab.present?
          if tab.include?(taxon.permalink)
            @sub_subcategory << [taxon.name, taxon.id]
          end
        else
          @sub_subcategory << [taxon.name, taxon.id]
        end
      end
      #@taxon_filters = Spree::Product.generate_new_filters(@subcategory_id)
    elsif params[:type].to_s == "sub_subcategories"
      @sub_subcategory_id = Spree::Taxon.where(id: params[:id]).first
      params[:s] = {} if params[:s].blank?
      params[:s][:brand_name] = @sub_subcategory_id.permalink
      @searcher = build_searcher(params)
      @searcher.retrieve_products
      @suppliers = Spree::Board.generate_brands(@searcher)
      @subcategory_id = Spree::Taxon.where(id: @sub_subcategory_id.parent.id).first
      @category_id = Spree::Taxon.where(id: @subcategory_id.parent.id).first
      @category_id.children.each do |taxon|
        if tab.present?
          if tab.include?(taxon.permalink)
            @subcategory << [taxon.name, taxon.id]
          end
        else
          @subcategory << [taxon.name, taxon.id]
        end
      end
      @subcategory_id.children.each do |taxon|
        if tab.present?
          if tab.include?(taxon.name)
            @sub_subcategory << [taxon.name, taxon.id]
          end
        else
          @sub_subcategory << [taxon.name, taxon.id]
        end
      end
      #@taxon_filters = Spree::Product.generate_new_filters(@sub_subcategory_id)
    end

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def design2

    #@board.messages.new(:sender_id => spree_current_user.id, :recipient_id => 0, :subject => "Publication Submission")
    @products = Spree::Product.all()
    @bookmarked_products = spree_current_user.bookmarks.collect { |bookmark| bookmark.product }
    @department_taxons = Spree::Taxonomy.where(:name => 'Department').first().root.children
    #@department_taxons= Spree::Supplier.find_by(id: 16).taxons 
    @searcher = build_searcher(params)

    @all_products = @searcher.retrieve_products.by_supplier('')
    @ary = Array.new(Array.new)

    @all_products.each do |prod|
      @prod = Spree::Product.find_by_id(prod.id)

      @prod.taxons.each do |tax|
        @ary.push([tax.name, tax.id])
      end
    end

    @suppliers = Spree::Supplier.where(:public => 1).order(:name)
    #@wholesaler_taxons = Spree::Taxonomy.where(:name => 'Wholesaler').first().root.children

    @color_collections = Spree::ColorCollection.all()
  end

  def destroy
    if @board
      @board.update(removal: true)
      Delayed::Job.enqueue DeleteRoomJob.new(@board.id)
      flash[:notice] = "The room has been deleted."
    else
      flash[:warning] = "We could not delete this room."
    end
    redirect_to designer_dashboard_path
  end

  private
  def prep_search_collections
    @room_taxons = Spree::Taxonomy.where(:name => 'Rooms').first().root.children.select { |child| Spree::Board.available_room_taxons.include?(child.name) }
    @style_taxons = Spree::Taxonomy.where(:name => 'Styles').first().root.children
    @colors = Spree::Color.order(:position)
    @designers = Spree::User.published_designers().order("created_at desc")
  end

  def board_params
    params.require(:board).permit(:name, :description, :style_id, :room_id, :status, :message, :featured, :featured_starts_at, :featured_expires_at, :board_commission, :featured_copy, :featured_headline)

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



