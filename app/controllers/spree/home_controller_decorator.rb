module Spree
  HomeController.class_eval do
    # before_filter :require_authentication
    
    def home2
      @slides = Spree::Slide.current.order("created_at desc") || Spree::Slide.defaults
      @page_photos = Spree::PagePhoto.where(active: true)
      @arrive_product = Spree::Product.where(new_arrival: true).where("new_arrival_until >= ?", DateTime.now.to_date)
      @designers = Spree::User.published_designers().order("created_at desc")
      @promoted_rooms = Spree::Board.promoted.limit(6)
      @home_text = Spree::HomeText.first
    end
    
   
  end
end