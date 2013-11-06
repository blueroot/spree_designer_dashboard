class Spree::DesignerRegistration < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :state, :postal_code, :phone, :website, :resale_certificate_number, :tin, :company_name, :status
  belongs_to :user, :class_name => "User"
  
  validates_presence_of :address1, :city, :state, :postal_code, :phone, :website, :resale_certificate_number, :tin, :company_name
  
  after_save :update_designer_status
  
  def self.status_options
    [["Pending Review","pending"], ["Accepted - Designer","accepted-designer"], ["Accepted - Affiliate Only","accepted-affiliate"], ["Declined","declined"]]
  end
  def update_designer_status
    user = self.user
    case self.status
      when "pending" || "declined"
        user.update_attributes({:is_discount_eligible => 0, :is_designer => 0})
      when "accepted-designer"
        user.update_attributes({:is_discount_eligible => 1, :is_designer => 1})
      when "accepted-affiliate"
        user.update_attributes({:is_discount_eligible => 1, :is_designer => 0})
    end
  end
  
  
end
