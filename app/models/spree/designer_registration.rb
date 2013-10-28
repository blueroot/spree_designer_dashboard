class Spree::DesignerRegistration < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :state, :postal_code, :phone, :website, :resale_certificate_number, :tin, :company_name, :status
  belongs_to :user, :class_name => "User"
  
  validates_presence_of :address1, :city, :state, :postal_code, :phone, :website, :resale_certificate_number, :tin, :company_name
  
  
  
end
