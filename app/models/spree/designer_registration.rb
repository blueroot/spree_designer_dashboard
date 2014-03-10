class Spree::DesignerRegistration < ActiveRecord::Base
  require 'mandrill'
  attr_accessible :address1, :address2, :city, :state, :postal_code, :phone, :website, :resale_certificate_number, :tin, :company_name, :status, :first_name, :last_name
  belongs_to :user, :class_name => "User"
  
  validates_presence_of :address1, :city, :state, :postal_code, :phone, :website, :tin, :company_name, :first_name, :last_name
  
  after_save :update_designer_status
  after_create :send_designer_welcome
  after_create :update_user_names
  
  def update_user_names
    user = self.user
    
    user.update_attributes({:first_name => self.first_name, :last_name => self.last_name})
    
  end
  
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
        self.send_room_designer_approval
      when "accepted-affiliate"
        user.update_attributes({:is_discount_eligible => 1, :is_designer => 0})
        self.send_trade_designer_approval
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
     :from_email=>"designer@scoutandnimble.com",
     :track_opens => true,
     :track_clicks => true,
     :url_strip_qs => false,
     :signing_domain => "scoutandnimble.com"
    }

    sending = m.messages.send_template('new-designer-registration', [{:name => 'main', :content => html_content}], message, true)

    logger.info sending
  
  end
  
  def send_room_designer_approval
    html_content = ''
    logger.info "Sending the mail to #{self.user.email}"

    m = Mandrill::API.new(MANDRILL_KEY)
    message = {
     :subject=> "Congratulations! Your application has been accepted!",
     :from_name=> "Jesse Bodine",
     :text=>"Now that you are an approved Room Designer with Scout & Nimble you may experience a loss of breath, dizziness, nausea, tingling and the need to celebrate. These feelings are completely normal and should be experienced daily from here on out. Thanks for signing up and welcome aboard. Your Room Designer account is now active, and we hope to have you desiging rooms very soon. In the meantime, please check out the tutorial below on how to navigate our site and build your rooms. If you have any questions along the way, do not hesitate to reach out to us. We are here to help!  \n\n The Scout & Nimble Team",
     :to=>[
       {
         :email=> self.user.email,
         :name=> self.user.full_name
       }
     ],
     :from_email=>"designer@scoutandnimble.com",
     :track_opens => true,
     :track_clicks => true,
     :url_strip_qs => false,
     :signing_domain => "scoutandnimble.com"
    }

    sending = m.messages.send_template('room-designer-approval', [{:name => 'main', :content => html_content}], message, true)

    logger.info sending
  
  end
  
  def send_trade_designer_approval
    html_content = ''
    logger.info "Sending the mail to #{self.user.email}"

    m = Mandrill::API.new(MANDRILL_KEY)
    message = {
     :subject=> "Congratulations! You have been accepted into the Scout & Nimble Trade Designer Program!",
     :from_name=> "Jesse Bodine",
     :text=>"You have been accepted into our Scout & Nimble Design Trade Program.  This allows you to shop our entire inventory of products from the best know retailers and get a discount on everything you purchase.  \n\n The Scout & Nimble Team",
     :to=>[
       {
         :email=> self.user.email,
         :name=> self.user.full_name
       }
     ],
     :from_email=>"designer@scoutandnimble.com",
     :track_opens => true,
     :track_clicks => true,
     :url_strip_qs => false,
     :signing_domain => "scoutandnimble.com"
    }

    sending = m.messages.send_template('trade-designer-congratulations', [{:name => 'main', :content => html_content}], message, true)

    logger.info sending
  
  end
  
  
end
