class Spree::ExtraController < Spree::StoreController
  before_filter :require_authenticationm, :except => [:mission]
  
  def our_suppliers
    
  end
  
  def tips_tricks
    
  end
  
  def video_tutorial
    
  end
  
  def mission
    #render :layout => "/spree/layouts/mission_layout"
  end
  
end