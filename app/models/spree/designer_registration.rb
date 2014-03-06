class Spree::DesignerRegistration < ActiveRecord::Base
  require 'mandrill'
  attr_accessible :address1, :address2, :city, :state, :postal_code, :phone, :website, :resale_certificate_number, :tin, :company_name, :status
  belongs_to :user, :class_name => "User"
  
  validates_presence_of :address1, :city, :state, :postal_code, :phone, :website, :tin, :company_name
  
  after_save :update_designer_status
  after_create :send_designer_welcome
  
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
  
  def send_designer_welcome
    html_content = ''
    logger.info "Sending the mail to #{self.user.email}"

    m = Mandrill::API.new(MANDRILL_KEY)
    message = {
     :subject=> "Thank you for submitting your application!",
     :from_name=> "Jesse Bodine",
     :text=>"Thanks for registering to be a Scout & Nimble room designer.  Please stay tuned as we'll be in touch soon!  \n\n The Scout & Nimble Team",
     :to=>[
       {
         :email=> self.user.email,
         :name=> self.user.full_name
       }
     ],
     :from_email=>"jesse@scoutandnimble.com",
     :track_opens => true,
     :track_clicks => true,
     :url_strip_qs => false,
     :signing_domain => "scoutandnimble.com"
    }

    sending = m.messages.send_template('new-designer-registration', [{:name => 'main', :content => html_content}], message, true)

    logger.info sending
  
  end
  
  
end
