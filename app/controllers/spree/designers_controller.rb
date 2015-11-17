class Spree::DesignersController < Spree::StoreController
  before_filter :require_authentication, :only => [:update]
  before_filter :set_section

  impressionist :actions => [:show]

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
    @user.user_images.destroy_all
    if params[:user].present? and params[:user][:user_images].present?
      base64 = (params[:user][:user_images][:attachment])
      data = Base64.decode64(base64['data:image/png;base64,'.length .. -1])
      file_img = File.new("#{Rails.root}/public/somefilename.png", 'wb')
      file_img.write data
      @image =  @user.user_images.new(attachment: file_img)
      if @image.save
        File.delete(file_img)
      end
      params[:user] = params[:user].except!(:user_images, :logo_image_attributes)


    end

    respond_to do |format|
      if @user.update_attributes(params[:user].permit!)
        format.html { redirect_to my_profile_path(format: 'html'), :notice => 'Your profile was successfully updated.', location: url_for( my_profile_path) }
      else
        format.html { redirect_to my_profile_path(format: 'html'), :notice => 'There was an error and your profile was not updated.', location: url_for( my_profile_path) }
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
    params.require(:user).permit(:first_name, :last_name, :description, :company_name, :website_url, :location, :blog_url, :email, :password, :password_confirmation,
                                 :is_discount_eligible, :is_beta_user, :can_add_boards, :designer_featured_starts_at, :designer_featured_ends_at, :designer_featured_position,
                                 :supplier_id, :marketing_images_attributes, :logo_image_attributes, :feature_image_attributes, :bill_address_id, :ship_address_id,
                                 :social_facebook, :social_twitter, :social_instagram, :social_pinterest, :social_googleplus, :social_linkedin, :social_tumblr,
                                 :username, :designer_quote, :marketing_images, :profile_display_name, :designer_commission, :show_designer_profile, :feature_image,
                                 :user_images_attributes)
  end

end



