class Spree::ExtraController < Spree::StoreController
  before_filter :require_authentication, :except => [:mission, :share_to_earn]
  
  def our_suppliers
    
  end
  
  def tips_tricks
    
  end
  
  def video_tutorial
    
  end
  
  def mission
    #render :layout => "/spree/layouts/mission_layout"
  end
  
  def share_to_earn
    
  end
  
end