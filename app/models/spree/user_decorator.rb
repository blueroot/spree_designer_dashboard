Spree::User.class_eval do
  has_many :boards, :foreign_key => :designer_id
  has_many :designer_registrations
  has_many :user_images, as: :viewable, dependent: :destroy, class_name: "Spree::UserImage"
  has_one :logo_image, as: :viewable, dependent: :destroy, class_name: "Spree::LogoImage"
  attr_accessible :user_images_attributes, :logo_image_attributes
  accepts_nested_attributes_for :user_images, :logo_image
  def self.is_active_designer
    where(:is_designer => 1)
  end
end