module Spree
  class FeatureImage < Asset
    
    #attr_accessible :alt, :attachment, :position, :viewable_type, :viewable_id

    has_attached_file :attachment,
                      styles: { mini: '48x48>', small: '100x100>', primary: '360x206#', primary_aspect: '360x206>', home: '540x300>', large: '600x600>', banner: '1200x1200>' },
                      default_style: :primary,
                      url: '/spree/feature_images/:id/:style/:basename.:extension',
                      path: 'feature_images/:id/:style/:basename.:extension',
                      convert_options: { all: '-strip -auto-orient -colorspace RGB' }

    validates_attachment_presence :attachment
    validate :no_attachment_errors

    # save the w,h of the original image (from which others can be calculated)
    # we need to look at the write-queue for images which have not been saved yet
    after_post_process :find_dimensions

#    include Spree::Core::S3Support
#    supports_s3 :attachment

    #Spree::Image.attachment_definitions[:attachment][:styles] = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles]).symbolize_keys!
    #Spree::Image.attachment_definitions[:attachment][:path] = Spree::Config[:attachment_path]
    #Spree::Image.attachment_definitions[:attachment][:url] = Spree::Config[:attachment_url]
    #Spree::Image.attachment_definitions[:attachment][:default_url] = Spree::Config[:attachment_default_url]
    #Spree::Image.attachment_definitions[:attachment][:default_style] = Spree::Config[:attachment_default_style]

    #used by admin user_images autocomplete
    def mini_url
      attachment.url(:mini, false)
    end

    def find_dimensions
      temporary = attachment.queued_for_write[:original]
      filename = temporary.path unless temporary.nil?
      filename = attachment.path if filename.blank?
      geometry = Paperclip::Geometry.from_file(filename)
      self.attachment_width  = geometry.width
      self.attachment_height = geometry.height
    end

    # if there are errors from the plugin, then add a more meaningful message
    def no_attachment_errors
      unless attachment.errors.empty?
        # uncomment this to get rid of the less-than-useful interrim messages
        # errors.clear
        errors.add :attachment, "Paperclip returned errors for file '#{attachment_file_name}' - check ImageMagick installation or image source file."
        false
      end
    end
  end
end