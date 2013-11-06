module Spree
  HomeController.class_eval do
    def dashboard
      @boards = spree_current_user.boards
    end
    
    def profile
      @user = spree_current_user
      @user.user_images.new if @user.user_images.blank?
      @user.build_logo_image if @user.logo_image.blank?
    end
  end
end