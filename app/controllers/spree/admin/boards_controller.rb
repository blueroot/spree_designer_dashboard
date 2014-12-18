class Spree::Admin::BoardsController < Spree::Admin::ResourceController
  before_filter :get_room_manager
  def load_resource
    #@board = Spree::Board.friendly.find(params[:id])
  end
  
  
  def list
    #@boards = Spree::Board.includes({:board_products => {:product => [{:master => :stock_items}, :supplier]}}, :board_image, :designer).page(params[:page]).per(params[:per_page] || 10)
    @boards = Spree::Board.includes({:board_products => {:product => [{:master => [:stock_items, :images, :prices]}, :supplier, :variants => [:stock_items, :prices, :images]]}}, :board_image, :designer).page(params[:page] || 1).per(params[:per_page] || 3)
    
    #@boards =  Spree::Board.joins(:board_products).select("spree_boards.*, count(spree_board_products.id) as product_count").group("spree_boards.id").page(params[:page]).per(params[:per_page] || 10)

    board_products = @boards.each.map(&:board_products).flatten(1)
    
    products       = board_products.map(&:product).compact

    @suppliers     = products.map(&:supplier).compact.uniq

    designers      = @boards.collect(&:designer).collect { |d| "#{d.first_name} #{d.last_name}"}.uniq

    @designer_names = ["All designers"] + designers
  end
  
  def index
    if params[:user_id]
      @user = Spree::User.find(params[:user_id])
      @boards = Spree::Board.by_designer(params[:user_id]).order("created_at desc").page(params[:page] || 1).per(params[:per_page] || 50)
    else  
      @boards = Spree::Board.all().order("created_at desc").page(params[:page] || 1).per(params[:per_page] || 50)
    end
  end

  def products
    @products_pending_approval_count  = Spree::Product.pending_approval.count > 0 ? "(#{Spree::Product.pending_approval.count})" : ""
    @products_marked_for_approval_count   = Spree::Product.marked_for_approval.count > 0 ? "(#{Spree::Product.marked_for_approval.count})" : ""
    @products_marked_for_removal_count    = Spree::Product.marked_for_removal.count > 0 ? "(#{Spree::Product.marked_for_removal.count})" : ""
    @products_published_count         = Spree::Product.published.count > 0 ? "(#{Spree::Product.published.count})" : ""
    @products_discontinued_count      = Spree::Product.discontinued.count > 0 ? "(#{Spree::Product.discontinued.count})" : ""
    
    if params[:product] and params[:product][:supplier_id]
      @supplier = Spree::Supplier.find(params[:product][:supplier_id])      
    else
      @supplier = nil
    end
    
    @state = params[:state] || "pending_approval"
    
    case @state
      when "pending_approval"
        if @supplier
          @products = @supplier.products.pending_approval.page(params[:page] || 1).per(params[:per_page] || 50)
        else
          @products = Spree::Product.pending_approval.page(params[:page] || 1).per(params[:per_page] || 50)
        end
      when "marked_for_approval"
        if @supplier
          @products = @supplier.products.marked_for_approval.page(params[:page] || 1).per(params[:per_page] || 50)
        else
          @products = Spree::Product.marked_for_approval.page(params[:page] || 1).per(params[:per_page] || 50)
        end
      when "marked_for_removal"
        if @supplier
          @products = @supplier.products.marked_for_removal.page(params[:page] || 1).per(params[:per_page] || 50)
        else
          @products = Spree::Product.marked_for_removal.page(params[:page] || 1).per(params[:per_page] || 50)
        end
      when "discontinued"
        if @supplier
          @products = @supplier.products.discontinued.page(params[:page] || 1).per(params[:per_page] || 50)
        else
          @products = Spree::Product.discontinued.page(params[:page] || 1).per(params[:per_page] || 50)
        end
      when "published"
        if @supplier
          @products = @supplier.products.published.page(params[:page] || 1).per(params[:per_page] || 50)
        else
          @products = Spree::Product.published.page(params[:page] || 1).per(params[:per_page] || 50)
        end
      else
        if @supplier
          @products = @supplier.products.pending_approval.page(params[:page] || 1).per(params[:per_page] || 50)
        else
          @products = Spree::Product.pending_approval.page(params[:page] || 1).per(params[:per_page] || 50)
        end
    end
    @suppliers_select = Spree::Supplier.select_options_by_status(@state, @supplier, false)
  end
  
  #def edit
  #  @board = Spree::Board.friendly.find(params[:id])

  #end

  def update
    @board = Spree::Board.friendly.find_by id: params[:id]
    if params[:state] == "deleted"
      # self.send_deletion_email(@board, params[:email][:reason]) if params[:email][:should_send]
      @board.delete_permanently!
    elsif params[:state] == "request_revision"
      # self.send_revision_email(@board, params[:email][:reason]) if params[:email][:should_send]
      @board.request_revision!
    elsif params[:state] == "published"
      # self.send_publication_email(@board, params[:email][:reason]) if params[:email][:should_send]
      @board.publish!
    end
    
    respond_to do |format|
      if @board.update_attributes(board_params)
        format.html {redirect_to edit_admin_board_path(@board, :notice => 'Your board was updated.')}
        format.json {render json: @board}
      else
        #format.html { render :action => ""}
      end
    end 
  end
  
  def approve
    @board  = Spree::Board.friendly.find_by id: params[:board][:id]
    @board.set_state_transition_context(params[:board][:state_message], spree_current_user)
    @board.publish
    @board.send_publication_email(params[:board][:state_message]) if params[:board][:send_message] == "on"
    
    respond_to do |format|
      format.js {  }
    end
  end
  
  def request_revision
    #@board  = Spree::Board.find_by id: params[:board][:id]
    @board.set_state_transition_context(params[:board][:state_message], spree_current_user)
    @board.request_designer_revision
    @room_manager.send_message(@board.designer, "Your room needs revisions.", "Please revise your room.")

    respond_to do |format|
      format.js {  }
    end
  end
  
  def approval_form
    @board  = Spree::Board.find_by id: params[:id]
    respond_to do |format|
      format.js {  }
    end
  end
  
  def revision_form
    @board  = Spree::Board.find_by id: params[:id]
    respond_to do |format|
      format.js {  }
    end
  end
  

  def new
    @board = Spree::Board.new(:name => "Untitled Room")
    @board.designer = spree_current_user
    @board.save!
  end
  
  
  
  def send_deletion_email(board, message)
   html_content = ''

   m = Mandrill::API.new(MANDRILL_KEY)
   message = {
    :subject=> "Sorry, your board was deleted.",
    :from_name=> "Jesse Bodine",
    :text=>"#{message} \n\n The Scout & Nimble Team",
    :to=>[
     {
       :email=> board.designer.email,
       :name=> board.designer.full_name
     }
     ],
     :from_email=>"designer@scoutandnimble.com",
     :track_opens => true,
     :track_clicks => true,
     :url_strip_qs => false,
     :signing_domain => "scoutandnimble.com"
   }

   sending = m.messages.send_template('board_deletion', [{:name => 'main', :content => html_content}], message, true)

   logger.info sending

 end

 def send_revision_email(board, message)
   html_content = ''

   m = Mandrill::API.new(MANDRILL_KEY)
   message = {
    :subject=> "Your room needs revision before it can be published.",
    :from_name=> "Jesse Bodine",
    :text=>"#{message} \n\n The Scout & Nimble Team",
    :to=>[
     {
       :email=> board.designer.email,
       :name=> board.designer.full_name
     }
     ],
     :from_email=>"designer@scoutandnimble.com",
     :track_opens => true,
     :track_clicks => true,
     :url_strip_qs => false,
     :signing_domain => "scoutandnimble.com"
   }

   sending = m.messages.send_template('board_revision', [{:name => 'main', :content => html_content}], message, true)

   logger.info sending   
 end
 
 
 private
  def board_params
    params.require(:board).permit(:name, :description, :style_id, :room_id, :status, :message, :featured, :featured_starts_at, :featured_expires_at, :board_commission, :featured_copy, :featured_headline)
    
  end
  
 
end
