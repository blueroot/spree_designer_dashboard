class Spree::MailboxController < Spree::StoreController
  before_filter :require_authentication, :except => [:mission]
  
  def inbox
    
  end
  
  def sentbox
    
  end
  
  def conversation
    @conversation = Mailboxer::Conversation.find(params[:id])
  end
  
  
end