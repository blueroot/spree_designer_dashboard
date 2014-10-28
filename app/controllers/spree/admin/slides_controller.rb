class Spree::Admin::SlidesController < Spree::Admin::ResourceController


 
  def index
    @current_slides = Spree::Slide.current
    @expired_slides = Spree::Slide.expired
    @upcoming_slides = Spree::Slide.upcoming
  end
  
  def new
    @slide = Spree::Slide.new
    @slide.build_slider_image
  end
  
  def create
    @slide = Spree::Slide.new(slide_params)
    if @slide.save
      redirect_to admin_slides_path
    else
    end
  end

  def edit
    @slide = Spree::Slide.find_by id: params[:id]
  end
  
  def update
    @slide = Spree::Slide.find_by id: params[:id]
    
    if @slide.update_attributes(slide_params)
      redirect_to edit_admin_slide_path(@slide, :notice => 'Your slide was updated.')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @slide = Spree::Slide.find_by id: params[:id]
    respond_to do |format|
      if @slide.destroy
        format.html {redirect_to admin_slide_path(@slide, :notice => 'Your slide was deleted.')}
        format.js {render :nothing => true, :status => 200, :layout => false}
        
      else
        #format.html { render :action => ""}
      end
    end 
    
    
    
  end

 
  private
    def slide_params
      params.require(:slide).permit(:name, :path, :is_default, :published_at, :expires_at, slider_image_attributes: [:attachment])
    end
  # redirect to the edit action after create
  #  create.response do |wants|
  #    wants.html { redirect_to edit_admin_fancy_thing_url( @fancy_thing ) }
  #  end
  #  
  #  # redirect to the edit action after update
  #  update.response do |wants|
  #    wants.html { redirect_to edit_admin_fancy_thing_url( @fancy_thing ) }
  #  end
 
end