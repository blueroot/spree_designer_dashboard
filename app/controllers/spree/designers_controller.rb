class Spree::DesignersController < Spree::StoreController
  

  

  def index
    @designers = Spree::User.is_active_designer()
  end
  

  
  def show
    @designer = Spree::User.is_active_designer().where(:id => params[:id]).first()
  end
  
  
   
end



