class Spree::ColorsController < Spree::StoreController

  def index
    if params[:color_collection_id]
      @color_collection = Spree::ColorCollection.find(params[:color_collection_id])
      @colors = @color_collection.colors
    else  
      @colors = Spree::Color.all()
    end
  end
  
  def get_color
    if !params[:swatch_val].blank?
      @color = Spree::Color.find_by_swatch_val(params[:swatch_val])
    else
      @color = nil
    end
    respond_to do |format|
      format.js   
    end
  
  end

  
 
end



