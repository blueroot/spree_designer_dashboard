object @board_product
attributes :id, :height, :rotation_offset, :top_left_x, :top_left_y, :width, :z_index, :center_point_x, :center_point_y
child :product do
  attributes :id, :slug, :name, :description
	node :image_url do |p|
	 image = Spree::Image.where(id: p.board_products.where(board_id: @board.id).first.image_id).first
    	   if image.present?
    	     image.attachment.url
    	     else
    	    p.images.first.attachment.url if !p.images.blank? and p.images.first.attachment
    	   end
	end
	child :variants do
	  attributes :id, :name, :description
		node :image_url do |v|
		   image = Spree::Image.where(id: v.product.board_products.where(board_id: @board.id).first.image_id).first
          	   if image.present?
          	     image.attachment.url
          	     else
          	     v.images.first.attachment.url if !v.images.blank? and v.images.first.attachment
          	   end

		end
		child :option_values do
			attributes :name
		end
	end
end
