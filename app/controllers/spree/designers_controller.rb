class Spree::DesignersController < Spree::StoreController
  before_filter :require_authentication
  before_filter :set_section 
  
  
  impressionist :actions=>[:show]


  def set_section
    @selected_section = "designers"
  end
  def index
    @designers = Spree::User.is_active_designer()
    
  end
  
  
  def tutorials
    
  end
  
  def update
    @user = spree_current_user
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to my_profile_path, :notice => 'Your profile was successfully updated.' }
      else
        format.html { redirect_to my_profile_path, :notice => 'There was an error and your profile was not updated.' }
      end
    end
    
    
  end
  
  
  def signup
    @designer = Spree::User.new
  end

  
  def show
    
    @designer = Spree::User.is_active_designer().where(:username => params[:username]).first
    
    if @designer and spree_current_user and (spree_current_user.is_beta_user? or spree_current_user.id == @designer.id)
      #@products = @designer.products.active
      @products = @designer.products
      render :action => "show"
    else
      redirect_to "/"
    end
  end
  
  
   
end



