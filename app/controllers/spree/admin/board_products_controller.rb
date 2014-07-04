class Spree::Admin::BoardProductsController < Spree::Admin::ResourceController
 
  def index
    
    #@board_products = Spree::BoardProduct.where( approved_at: nil, removed_at: nil).page(params[:page]).per(params[:per_page] || 50).includes({:product => [{:master => [:stock_items, :images]}, :supplier]}, :board)
    #@board_products = Spree::BoardProduct.all.includes(:board, :product => [:supplier, { :variants => :stock_items }] ).page(params[:page]).per(params[:per_page] || 50)
    
    if params[:supplier_id]
      @supplier = Spree::Supplier.find(params[:supplier_id])
      @board_products = @supplier.board_products.where( "isnull(spree_board_products.removed_at) and isnull(spree_board_products.approved_at)" ).includes({:product => [{:master => [:stock_items, :images]}]}, :board).page(params[:page] || 1).per(params[:per_page] || 10)
    else
      @board_products = Spree::BoardProduct.where( approved_at: nil, removed_at: nil).includes({:product => [{:master => [:stock_items, :images]}, :supplier]}, :board).page(params[:page] || 1).per(params[:per_page] || 50)
    end

    #@board_products = Spree::BoardProduct.all.includes(:board, :product => [:supplier, { :variants => :stock_items }] ).page(params[:page]).per(params[:per_page] || 50)
    #@boards         = @board_products.map(&:board).uniq.compact

    @products       = @board_products.map(&:product).compact
    @suppliers      = @products.map(&:supplier).compact.uniq
    @supplier_names = ["All suppliers",0] + @suppliers.collect{|supplier| [supplier.name, supplier.id]}.compact.uniq
  end

  def update
    @board_product  = Spree::BoardProduct.find_by id: params[:id]
    @product        = Spree::Product.find_by id: params[:product_id]
    @variant        = Spree::Variant.find_by id: params[:variant_id]
    @stock_item     = Spree::StockItem.find_by id: params[:stock_item_id]

    stock_change_amount = params[:stock_item][:count_on_hand].to_i - @stock_item.count_on_hand
    @stock_movement = Spree::StockMovement.new(stock_item_id: @stock_item.id, quantity: stock_change_amount, action: "received")
    @stock_movement.save
    @board_product.update_attributes(board_product_params)

    @product.update_attributes(product_params)

    @variant.update_attributes(variant_params, without_protection: true)

    @stock_item.update_attributes(stock_item_params, without_protection: true)

    respond_to do |format|
      format.json { render json: { status: 200 } }
    end
  end

  private
    def board_product_params
      params.require(:board_product).permit!
    end

    def product_params
      params.require(:product).permit!
    end

    def variant_params
      params.require(:variant).permit!
    end

    def stock_item_params
      params.require(:stock_item).permit(:supplier_count_on_hand, :backorderable)
    end
 
end
