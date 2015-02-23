module Spree
  HomeController.class_eval do
    before_filter :require_authentication
    
    def home2
      @slides = Spree::Slide.current.order("created_at desc") || Spree::Slide.defaults
      
      @promoted_rooms = Spree::Board.promoted
    end
    
   
  end
end