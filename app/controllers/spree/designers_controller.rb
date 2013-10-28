class Spree::DesignersController < Spree::StoreController
  #before_filter :require_authentication,  :only => [:signup]

  

  def index
    @designers = Spree::User.is_active_designer()
    
  end
  
  
  def signup
    @designer = Spree::User.new
  end

  
  def show
    @designer = Spree::User.is_active_designer().where(:id => params[:id]).first()
    @designers = Spree::User.is_active_designer()
  end
  
  
   
end



