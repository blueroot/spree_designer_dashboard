class Spree::Slide < ActiveRecord::Base
  has_one :slider_image, as: :viewable, order: :position, dependent: :destroy, class_name: "Spree::SliderImage"
  accepts_nested_attributes_for :slider_image
  
  def self.current
    where("published_at <= ? and expires_at >= ?", Date.today, Date.today)
  end
  
  def self.upcoming
    where("published_at > ?", Date.today)
  end
  
  def self.expired
    where("expires_at < ?", Date.today)
  end
  
  def self.defaults
    where("is_default = 1")
  end
  
end