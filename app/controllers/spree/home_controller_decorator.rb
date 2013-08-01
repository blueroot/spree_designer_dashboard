module Spree
  HomeController.class_eval do
    def dashboard
      
    end
    
    def profile
      @board = Spree::Board.new
    end
  end
end