class Spree::ColorsController < Spree::StoreController

  def index
    @colors = Spree::Color.all()
  end
  
 
end



