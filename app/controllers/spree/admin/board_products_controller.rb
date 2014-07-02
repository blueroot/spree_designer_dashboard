class Spree::Admin::BoardProductsController < Spree::Admin::ResourceController
 
  def index
    #@board_products = Spree::BoardProduct.where( approved_at: nil, removed_at: nil).page(params[:page]).per(params[:per_page] || 50).includes({:product => [{:master => [:stock_items, :images]}, :supplier]}, :board)
     @board_products = Spree::BoardProduct.where( approved_at: nil, removed_at: nil).includes({:product => [{:master => [:stock_items, :images]}, :supplier]}, :board) 

    #@board_products = Spree::BoardProduct.all.includes(:board, :product => [:supplier, { :variants => :stock_items }] ).page(params[:page]).per(params[:per_page] || 50)
    #@boards         = @board_products.map(&:board).uniq.compact

    @products       = @board_products.map(&:product).compact
    @suppliers      = @products.map(&:supplier).compact.uniq
    @supplier_names = ["All suppliers"] + @suppliers.map(&:name).compact.uniq
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
      params.require(:board_product).permit(:status)
    end

    def product_params
      params.require(:product).permit(:name, :sku, :price, :cost_price)
    end

    def variant_params
      params.require(:variant).permit(:map_price, :msrp_price, :shipping_height, :shipping_width, :shipping_depth)
    end

    def stock_item_params
      params.require(:stock_item).permit(:supplier_count_on_hand)
    end
 
end
