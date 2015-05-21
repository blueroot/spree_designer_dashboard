collection @board_products
attributes :id, :height, :rotation_offset, :top_left_x, :top_left_y, :width, :z_index, :center_point_x, :center_point_y
child :product do
  attributes :slug, :name, :description
	node :image_url do |p|
	  image = Spree::Image.where(id: p.board_products.where(board_id: @board.id).first.image_id).first
	   if image.present?
	     image.attachment.url
	     else
	     p.images.first.attachment.url if !p.images.blank? and p.images.first.attachment
	   end

	end
end

