object @board_product
child :product do
  attributes :permalink, :name, :description
	node :image_url do |p|
	  p.images.first.attachment.url if !p.images.blank? and p.images.first.attachment
	end
end
