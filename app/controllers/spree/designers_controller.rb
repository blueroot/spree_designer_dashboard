class Spree::DesignersController < Spree::StoreController
  #before_filter :require_authentication,  :only => [:signup]

  impressionist :actions=>[:show]

  def index
    @designers = Spree::User.is_active_designer()
    
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
    @designer = Spree::User.is_active_designer().where(:id => params[:id]).first()
    @designers = Spree::User.is_active_designer()
  end
  
  
   
end



