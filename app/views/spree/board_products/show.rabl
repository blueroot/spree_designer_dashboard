object @board_product
attributes :id, :height, :rotation_offset, :top_left_x, :top_left_y, :width, :z_index
child :product do
  attributes :id, :slug, :name, :description
	node :image_url do |p|
	  p.images.first.attachment.url if !p.images.blank? and p.images.first.attachment
	end
	child :variants do
	  attributes :id, :name, :description
		node :image_url do |v|
		  v.images.first.attachment.url if !v.images.blank? and v.images.first.attachment
		end
		child :option_values do
			attributes :name
		end
	end
end
