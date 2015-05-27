class Spree::DesignersController < Spree::StoreController
  before_filter :require_authentication, :only => [:update]
  before_filter :set_section 
  
  impressionist :actions=>[:show]

  def set_section
    @selected_section = "designers"
  end

  def index
    @designers = Spree::User.published_designers().order("created_at desc")
  end
  
  def tutorials
    
  end
  
  def update
    @user = spree_current_user
    respond_to do |format|
      if @user.update_attributes(designer_params)
        format.html { redirect_to my_profile_path, :notice => 'Your profile was successfully updated.' }
      else
        format.html { redirect_to my_profile_path, :notice => 'There was an error and your profile was not updated.' }
      end
    end    
  end
  
  def signup
    @designer = Spree::User.new
  end
  
  def show
    @designer = Spree::User.is_active_designer().where(:username => params[:username]).first
    @products = []
    @products = @designer.products.available_through_published_boards if @designer.present?
    render :action => "show"
  end
  
  private 
    def designer_params
      params.require(:user).permit(:first_name, :last_name, :description, :company_name, :website_url, :location, :blog_url, :email, :password, :password_confirmation, :is_discount_eligible, :is_beta_user, :can_add_boards, :designer_featured_starts_at, :designer_featured_ends_at, :designer_featured_position, :supplier_id, :marketing_images_attributes, user_images_attributes: [:attachment], :logo_image_attributes, :feature_image_attributes,  :bill_address_id, :ship_address_id, :social_facebook, :social_twitter, :social_instagram, :social_pinterest, :social_googleplus, :social_linkedin, :social_tumblr, :username, :designer_quote, :marketing_images, :profile_display_name, :designer_commission, :show_designer_profile, :feature_image)
    end
   
end



