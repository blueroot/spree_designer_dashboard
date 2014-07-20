class Spree::Admin::BoardsController < Spree::Admin::ResourceController

  def index
    #@boards = Spree::Board.includes({:board_products => {:product => [{:master => :stock_items}, :supplier]}}, :board_image, :designer).page(params[:page]).per(params[:per_page] || 10)
    @boards = Spree::Board.includes({:board_products => {:product => [{:master => [:stock_items, :images, :prices]}, :supplier, :variants => [:stock_items]]}}, :board_image, :designer).page(params[:page] || 1).per(params[:per_page] || 3)
    
    #@boards =  Spree::Board.joins(:board_products).select("spree_boards.*, count(spree_board_products.id) as product_count").group("spree_boards.id").page(params[:page]).per(params[:per_page] || 10)

    board_products = @boards.each.map(&:board_products).flatten(1)
    
    products       = board_products.map(&:product).compact

    @suppliers     = products.map(&:supplier).compact.uniq

    designers      = @boards.collect(&:designer).collect { |d| "#{d.first_name} #{d.last_name}"}.uniq

    @designer_names = ["All designers"] + designers
  end

  def update
    @board = Spree::Board.find_by id: params[:id]
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
      if @board.update_attributes(params[:board])
        format.html {redirect_to edit_admin_board_path(@board, :notice => 'Your board was updated.')}
        format.json {render json: @board}
      else
        #format.html { render :action => ""}
      end
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

 def send_publication_email(board, message)
  html_content = ''

  m = Mandrill::API.new(MANDRILL_KEY)
  message = {
    :subject=> "Your room was published!",
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

   sending = m.messages.send_template('board_publication', [{:name => 'main', :content => html_content}], message, true)

   logger.info sending   
 end

end
