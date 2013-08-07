module Spree
  HomeController.class_eval do
    def dashboard
      
    end
    
    def profile
      @user = spree_current_user
    end
  end
end