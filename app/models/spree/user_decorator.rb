Spree::User.class_eval do
  has_many :boards, :foreign_key => :designer_id
  has_many :products, :through => :boards
  has_many :designer_registrations
  has_many :user_images, as: :viewable, dependent: :destroy, class_name: "Spree::UserImage"
  has_many :marketing_images, as: :viewable, dependent: :destroy, class_name: "Spree::MarketingImage"
  has_one :logo_image, as: :viewable, dependent: :destroy, class_name: "Spree::LogoImage"
  accepts_nested_attributes_for :user_images, :logo_image, :marketing_images
  is_impressionable
  
  def is_designer?
    self.is_designer || self.can_add_boards
  end

  def is_affiliate?
    self.is_discount_eligible
  end
  
  def self.is_active_designer
    where(:can_add_boards => 1)
  end
  
end
