Spree::User.class_eval do
  has_many :boards, :foreign_key => :designer_id, :order => "created_at desc"
  has_many :products, :through => :boards
  has_many :bookmarks
  has_many :designer_registrations
  has_many :user_images, as: :viewable, dependent: :destroy, class_name: "Spree::UserImage"
  has_many :marketing_images, as: :viewable, dependent: :destroy, class_name: "Spree::MarketingImage"
  has_one :logo_image, as: :viewable, dependent: :destroy, class_name: "Spree::LogoImage"
  has_one :feature_image, as: :viewable, dependent: :destroy, class_name: "Spree::FeatureImage"
  accepts_nested_attributes_for :user_images, :logo_image, :marketing_images, :feature_image
  is_impressionable
  
  def self.designers
    where("can_add_boards = 1 or is_discount_eligible = 1")
  end
  
  def self.published_designers
    where(:show_designer_profile => 1)
  end
  
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
