module Spree
  HomeController.class_eval do
    before_filter :require_authentication
    def dashboard
      @boards = spree_current_user.boards
    end
    
    def profile
      @user = spree_current_user
      if spree_current_user and (spree_current_user.is_beta_user? or spree_current_user.is_designer?)
        
        @user.user_images.new if @user.user_images.blank?
        @user.marketing_images.new if @user.marketing_images.blank?
        @user.build_logo_image if @user.logo_image.blank?
      else
        redirect_to "/"
      end
    end
  end
end