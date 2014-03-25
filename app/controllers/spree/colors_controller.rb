class Spree::ColorsController < Spree::StoreController

  def index
    if params[:color_collection_id]
      @color_collection = Spree::ColorCollection.find(params[:color_collection_id])
      @colors = @color_collection.colors
    else  
      @colors = Spree::Color.all()
    end
  end
  
 
end



