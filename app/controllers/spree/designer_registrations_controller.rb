class Spree::DesignerRegistrationsController < Spree::StoreController
  before_action :set_designer_registration, only: [:show, :edit, :update, :destroy]
  layout "/spree/layouts/splash"
  
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
      tracker = Mixpanel::Tracker.new(MIXPANEL_PROJECT_TOKEN)
      tracker.track(current_spree_user.id, 'Registered as Designer')
      tracker.people.set(current_spree_user.id, {
          'Company'           => @designer_registration.company_name,
          'Address 1'         => @designer_registration.address1,
          'Address 2'         => @designer_registration.address2,
          'City'              => @designer_registration.city,
          'State'             => @designer_registration.state,
          'Postal Code'       => @designer_registration.postal_code,
          'Website'           => @designer_registration.website,
          'Phone'             => @designer_registration.phone,
          'Status'            => @designer_registration.status,
          'Registration Date' => @designer_registration.created_at
      });
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
