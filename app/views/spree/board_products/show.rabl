object @board_product
attributes :id, :height, :rotation_offset, :top_left_x, :top_left_y, :width, :z_index
child :product do
  attributes :permalink, :name, :description
	node :image_url do |p|
	  p.images.first.attachment.url if !p.images.blank? and p.images.first.attachment
	end
end
