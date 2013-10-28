class Spree::DesignerRegistrationsController < Spree::StoreController
  before_action :set_designer_registration, only: [:show, :edit, :update, :destroy]

  # GET /designer_registrations
  def index
    @designer_registrations = Spree::DesignerRegistration.all
  end

  # GET /designer_registrations/1
  def show
  end

  # GET /designer_registrations/new
  def new
    @designer_registration = Spree::DesignerRegistration.new
  end

  # GET /designer_registrations/1/edit
  def edit
  end

  # POST /designer_registrations
  def create
    @designer_registration = current_spree_user.designer_registrations.new(designer_registration_params)

    if @designer_registration.save
      redirect_to designer_registration_thanks_path
    else
      render action: 'new'
    end
  end
  
  def thanks
    
  end

  # PATCH/PUT /designer_registrations/1
  def update
    if @designer_registration.update(designer_registration_params)
      redirect_to @designer_registration, notice: 'Designer registration was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /designer_registrations/1
  def destroy
    @designer_registration.destroy
    redirect_to designer_registrations_url, notice: 'Designer registration was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_designer_registration
      @designer_registration = Spree::DesignerRegistration.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def designer_registration_params
      params[:designer_registration]
    end
end
