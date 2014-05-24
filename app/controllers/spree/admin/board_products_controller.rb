class Spree::Admin::BoardProductsController < Spree::Admin::ResourceController


 
  def index
    # params[:q] ||= {}
    # @show_only_featured_boards = params[:q][:featured_not_false].present?
    # #params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'

    # # As date params are deleted if @show_only_completed, store
    # # the original date so we can restore them into the params
    # # after the search
    # created_at_gt = params[:q][:created_at_gt]
    # created_at_lt = params[:q][:created_at_lt]

    # if !params[:q][:created_at_gt].blank?
    #   params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
    # end

    # if !params[:q][:created_at_lt].blank?
    #   params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
    # end

    # @search = Spree::BoardProduct.accessible_by(current_ability, :index).ransack(params[:q])
    # @board_products = @search.result.page(params[:page]).
    #   per(params[:per_page] || 50)

    # # Restore dates
    # params[:q][:created_at_gt] = created_at_gt
    # params[:q][:created_at_lt] = created_at_lt

    @boards         = Spree::Board.all
    @board_products = Spree::BoardProduct.all.select {|bp| bp.approved_at == nil && bp.removed_at == nil  }
    @products       = @board_products.map(&:product).compact
    @suppliers      = @products.map(&:supplier).compact.uniq
    @supplier_names = @suppliers.map(&:name).compact.uniq

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
